#include "FlashLib.h"
#include "StringPrint.h"
#include "petscii.c"
#include "IrqHack64.h"
#include "Transfer.h"
#include "DirFunction.h"
#include <EEPROM.h>
#include <SPI.h>
#include <SdFat.h>
#include <SdFatUtil.h>

SdFat sd;
SdFile   dirFile;
SdFile   file;
DirFunction dirFunc;
const int stateNone = 0;
const int statePressed = 1;
const int stateReleased = 2;

const int stateBoot = 0;
const int stateMenu = 1;
const int stateGame = 2;


int state = stateNone;
long elapsed = 0;
long pressTime = 0;

int cartridgeState = stateBoot;

const int chipSelect = 10;

volatile unsigned char receivedByte;
volatile unsigned long timeDifference;
volatile bool irqInit = false;
volatile bool received = false;
volatile long StartTime;
volatile long LastTime;

volatile int mask = 128;
volatile long timeDifArray[8];
volatile int index = 0;

void ShowMem() {
  Serial.print(F("Free RAM: "));
  Serial.println(FreeRam());    
}

#ifdef DEBUG
void TransferInfo(long transferLength, long padBytes, byte transferPages)
{
    Serial.print(F("BLK X : ")); Serial.println(GetBlockIndex());
    Serial.print(F("XF X : ")); Serial.println(GetTransferIndex());
    Serial.print(F("XFD LEN : ")); Serial.println(GetBlockIndex() * 256 + GetTransferIndex());  
    Serial.print(F("TO XF : ")); Serial.println(transferLength + padBytes);
    Serial.print(F("TO XF BLKS")); Serial.println(transferPages);    
}
#endif 

void serialInput() {
  if (irqInit) {    
    timeDifference = millis() - LastTime;
    LastTime = millis();
    if (index<8) {
      timeDifArray[index] = timeDifference;
      index++;   
      if (index == 8) {
        detachInterrupt(0);
        received = true;  
      }
    } else {
      #ifdef DEBUG 
        Serial.println(F("Err!!"));
      #endif
    }
  } else {
    index = 0;
    mask = 128;
    StartTime = millis();
    LastTime = StartTime;    
    irqInit = true;
  }
}



void printOptions(void) {
  Serial.println(F("---- IrqHack64 by I.R.on----"));
  Serial.println(F("1. Receive program"));          
  Serial.println(F("2. Send menu from micro's flash"));      
  Serial.println(F("3. Reset C64"));  
  Serial.println(F("4. Reset C64 No Cart"));          
  #ifdef DEBUG
  Serial.println(F("6. Dump received"));     
  #endif
  Serial.println();
  Serial.println();
  
  #ifdef DEBUG 
  ShowMem();
  #endif
}

void setup() {
  ResetSetup();
  NmiSetup();
  
  pinMode(IRQ, INPUT);
  pinMode(EXROM, OUTPUT);    
  digitalWrite(EXROM, HIGH);    
  pinMode(SEL, INPUT);  
  digitalWrite(SEL, HIGH); //Activate internal pullup
  
  setAddressPinsOutput();
  Serial.begin(57600);
  
  
  if (!sd.begin(chipSelect, SPI_FULL_SPEED)) {  
      Serial.println(F("Can't initialize!"));
      sd.initErrorHalt();
  } else {    
      uint32_t cardSize  = sd.card()->cardSize();
      if (cardSize == 0) {
        Serial.println(F("cardSize failed"));
        return;
      }
      
      Serial.println(F("\nCard type: "));
      switch (sd.card()->type()) {
      case SD_CARD_TYPE_SD1:
        Serial.println(F("SD1"));
        break;
    
      case SD_CARD_TYPE_SD2:
        Serial.println(F("SD2"));
        break;
    
      case SD_CARD_TYPE_SDHC:
        if (cardSize < 70000000) {
          Serial.println(F("SDHC"));
        } else {
          Serial.println(F("SDXC"));
        }
        break;
      default:
      Serial.println(F("Unknown\n"));
      }                  
  }
  
  printOptions();
  dirFunc.SetSd(&sd);
  dirFunc.ToRoot();
  dirFunc.Prepare();
  
  /*
  InitEprom();
  RestoreBootOption();
  */
  
}



void StartListening() {
  attachInterrupt(0, serialInput, FALLING);  
  timeDifference = 0;
  irqInit = false;
  received = false;
  index = 0;  
}

void EndListening() {
  detachInterrupt(0);
  timeDifference = 0;
  irqInit = false;
  received = false;
  index = 0;  
}


const unsigned int nMax = 20;

byte currentItemsCount = 0;
byte currentPageIndex = 0;
byte count = 0;
byte pageCount = 0;
byte currentIndex = 0;

void TransferMenu() {
  File currentFile;
  unsigned char readFromFile = 0;
  count = 0;
  EndListening();  
  
  dirFunc.ToRoot();
  dirFunc.Prepare();  
  if (sd.exists("irqhack64.prg")) {
    currentFile = sd.open("irqhack64.prg");
    if (currentFile) {
      #ifdef DEBUG
        Serial.println(F("Menu from SD"));
      #endif      
      readFromFile = 1;
    } 
  }

  int menu_data_length = (readFromFile? currentFile.size() : data_len) ;
  EnableCartridge();
  ResetC64();
  
  
  delay(2100);
  

  unsigned char low;
  unsigned char high;

  if (!readFromFile) {
    low = pgm_read_byte(cartridgeData);  
    high = pgm_read_byte(cartridgeData+1);  
  } else {
    low = currentFile.read();
    high = currentFile.read();    
  }
  
  long fileNamesDataLength = 16 + nMax * 32; // 16 byte header + 
  long transferLength = menu_data_length + fileNamesDataLength - 2;
  long padBytes = (transferLength%256==0) ? 0 : 256 - transferLength%256; 
  byte transferPages = (byte)(transferLength/256 + (padBytes>0 ? 1 : 0));  
  
  TransmitByteSlow(low);
  TransmitByteSlow(high);
  TransmitByteSlow(transferPages); //was 2A
  TransmitByteSlow(0x00); 
  ResetIndex();
  #ifdef DEBUG   
    Serial.println(F("Loading")); 
  #endif

  if (!readFromFile) {
    for (int i=2;i<menu_data_length;i++) {
     unsigned char value = pgm_read_byte(cartridgeData+i);    
     TransmitByteFastNew(value); 
    }  
  } else {
    for (int i=2;i<menu_data_length;i++) {
     unsigned char value = currentFile.read();   
     TransmitByteFastNew(value); 
    }     
  }

  
  currentItemsCount = dirFunc.GetCount()>nMax ? nMax : dirFunc.GetCount();
  int padValue = (currentItemsCount % nMax) == 0 ? 0 : nMax - (currentItemsCount % nMax);
  pageCount = (byte)(dirFunc.GetCount()/nMax + (padValue>0 ? 1 : 0));    
  currentIndex = 0;
  currentPageIndex = 0;
  

  TransmitByteFastNew(currentItemsCount); 
  
  TransmitByteFastNew(pageCount); 
  
  TransmitByteFastNew(currentPageIndex); 

  for (int i = 0;i<13;i++)     TransmitByteFastNew(0); //Fill reserved area
  unsigned int n = 0;
  dirFunc.Rewind();
  //Send initial state of directories.
  while (n<nMax && dirFunc.Iterate()) {   
    if (!dirFunc.IsHidden) {
      #ifdef DEBUG       
      Serial.println(dirFunc.CurrentFileName.value);    
      #endif
      for (int i=0;(i<dirFunc.CurrentFileName.index) && (i<32);i++) {
        TransmitByteFastNew(cbm_ascii2petscii_c(tolower(dirFunc.CurrentFileName.value[i]))); 
      }      
      
      for (int i=dirFunc.CurrentFileName.index;i<32;i++) {
        TransmitByteFastNew(0x00);
      }
  
      n++;
    }
  }    

  #ifdef DEBUG 
  Serial.print(F("ITM CNT:")); Serial.println(n);
  #endif
  for (int i = n;i<nMax;i++) {
    for (int j = 0;j<32;j++) {
      TransmitByteFastNew(0x00); 
    } 
  }  
  
  if (padBytes>0) {
    for (int i=0;i<padBytes;i++) {    
      TransmitByteFastNew(0xEA); 
    }
  }
  
  #ifdef DEBUG 
  Serial.print(F("CNT:"));Serial.println(dirFunc.GetCount());

  Serial.print(F("PG ITEM CNT:"));Serial.println(currentItemsCount);
  Serial.print(F("PG CNT:"));Serial.println(pageCount);
  
  TransferInfo(transferLength, padBytes, transferPages);
  #endif
  
  delay(10);
  DisableCartridge();
  delay(500);
  StartListening();
  #ifdef DEBUG
  Serial.println(F("Done"));
  #endif

  if (readFromFile && currentFile) currentFile.close();  
  
  
}

void TransferDirectory(int startIndex) {
  EndListening();  
  StartListening();      
  EnableCartridge();
  
  unsigned char low = 0xF0;  
  unsigned char high = 0x1C;

  long fileNamesDataLength = 16 + 20 * 32; // 16 byte header + 
  long transferLength = fileNamesDataLength;
  long padBytes = (transferLength%256==0) ? 0 : 256 - transferLength%256;  
  byte transferPages = (byte)(transferLength/256 + (padBytes>0 ? 1 : 0));  
  
  currentItemsCount = dirFunc.GetCount()-startIndex>nMax ? nMax : dirFunc.GetCount()-startIndex;
  int padValue = (currentItemsCount % nMax) == 0 ? 0 : nMax - (currentItemsCount % nMax);
  pageCount = (byte)(dirFunc.GetCount()/nMax + (padValue>0 ? 1 : 0));      
  
  ResetIndex();
  #ifdef DEBUG   
  Serial.println(F("XFER DIR")); 
  Serial.print(F("CNT:"));Serial.println(dirFunc.GetCount());
  Serial.print(F("PP ITEM CNT:"));Serial.println(currentItemsCount);
  Serial.print(F("PG CNT:"));Serial.println(pageCount);
  Serial.print(F("CP:"));Serial.println(currentPageIndex);  
  #endif
  
  TransmitByteFastNew(currentItemsCount); 
  
  TransmitByteFastNew(pageCount); 
  
  TransmitByteFastNew(currentPageIndex); 

  for (int i = 0;i<13;i++)     TransmitByteFastNew(0); //Fill reserved area
  
  unsigned int n = 0;
  int itemIndex = 0;
  dirFunc.Rewind();
  //Send initial state of directories.
  while (n<255 && itemIndex<nMax && dirFunc.Iterate() && !dirFunc.IsFinished) {  
    if (!dirFunc.IsHidden) {  
      if (n>=currentIndex) {
        // Print the file number and name. 
        #ifdef DEBUG         
        Serial.println(dirFunc.CurrentFileName.value);
        #endif
        
        for (int i=0;(i<dirFunc.CurrentFileName.index) && (i<32);i++) {
          TransmitByteFastNew(cbm_ascii2petscii_c(tolower(dirFunc.CurrentFileName.value[i]))); 
          //TransmitByteFastNew(0x42);
        }
        
        for (int i=dirFunc.CurrentFileName.index;i<32;i++) {
          TransmitByteFastNew(0x00);
        }
        
        itemIndex++;
      }
      n++;
    } 
  }   

  #ifdef DEBUG   
  Serial.print(F("FL CNT:")); Serial.println(n);
  #endif
  for (int i = itemIndex;i<nMax;i++) {
    for (int j = 0;j<32;j++) {
      TransmitByteFastNew(0x00); 
    } 
  }  
  
  if (padBytes>0) {
    for (int i=0;i<padBytes;i++) {    
      TransmitByteFastNew(0xEA); 
    }
  }
  
  #ifdef DEBUG   
  TransferInfo(transferLength, padBytes, transferPages);
  #endif
  
  delay(10);
  DisableCartridge();
  #ifdef DEBUG
  Serial.println(F("Done"));    
  #endif
}

void TransferDirectoryNext() {
  if (currentIndex<dirFunc.GetCount()-nMax) {
    currentIndex = currentIndex + nMax;
    currentPageIndex++;
  }
  
  TransferDirectory(currentIndex);
}

void TransferDirectoryPrevious() {
  if (currentIndex>=nMax) {
    currentIndex = currentIndex - nMax;
    currentPageIndex--;
  }
  
  TransferDirectory(currentIndex);  
}

void InvokeSelected(int selected) {
  #ifdef DEBUG   
  Serial.print(F("SEL:"));Serial.println(selected);
  #endif
  unsigned int n = 0;
  unsigned int i = 0;
  dirFunc.Rewind();
  while (n<255 && dirFunc.Iterate()) { 
    i = i + 1; 
    if (!dirFunc.IsFinished && !dirFunc.IsHidden) {  
      #ifdef DEBUG       
      //Serial.print(F("n : "));Serial.println(n);      
      //Serial.print(F("Current page index : "));Serial.println(currentIndex);
      #endif
      if (n>=currentIndex) {        
        if (n-currentIndex == selected) {
          #ifdef DEBUG 
          Serial.print(F("SEL FL:")); Serial.println(dirFunc.CurrentFileName.value);
          #endif
          if (dirFunc.IsDirectory) {
            #ifdef DEBUG 
            Serial.println(F("DIR!"));
            #endif
            if (!strcmp(dirFunc.CurrentFileName.value, "..")) {
              #ifdef DEBUG
              Serial.println(F("TO ROOT"));
              #endif
              dirFunc.GoBack();
            } else {
              dirFunc.ChangeDirectory(dirFunc.CurrentFileName.value);                          
            }
            dirFunc.Prepare();
            currentIndex = 0;
            TransferDirectory(currentIndex);
            break;             
          } else {
            dirFunc.SetSelected(selected);
            TransferGame(dirFunc.CurrentFileName);                    
          }
        }       
      }
      n++; 
    } 
  }   
}

const size_t BUF_SIZE = 16;
uint8_t buf[BUF_SIZE];  

void TransferGame(StringPrint selectedFile) {
  EndListening();
  #ifdef DEBUG   
  Serial.print(F("OPENING:")); Serial.println(selectedFile.value);
  ShowMem();
  #endif
  
  File currentFile = sd.open(selectedFile.value);
  if (currentFile) {
   #ifdef DEBUG 
   Serial.print(currentFile.size()); Serial.println(F(" bytes"));   
   #endif

    long transferLength = currentFile.size() - 2;
    long padBytes = (transferLength%256==0) ? 0 : 256 - transferLength%256; 
    byte transferPages = (byte)(transferLength/256 + (padBytes>0 ? 1 : 0));
    ResetIndex();
    EnableCartridge();
    ResetC64();
  
    delay(2100);
    //delay(500);
    
    int c = 0;
    int index = 0;
    unsigned char low;
    unsigned char high;
    unsigned char data;
    int readCount = 0;
    Serial.println(F("Loading"));
    pressTime = millis();
    if(currentFile.available() > 1) {
      
      readCount = currentFile.read(buf, 2);
  
      if (readCount > 0) {
        for (int i = 0;i<readCount;i++) {               
          data = buf[i];          
          if (index==0) {
              TransmitByteSlow(data);
          } else if (index == 1) {
              TransmitByteSlow(data);
              TransmitByteSlow(transferPages); 
              TransmitByteSlow(0x00);     
          } 
          index++;
        }
      }
    }
    
    while(currentFile.available() > 0) {      
      readCount = currentFile.read(buf, sizeof(buf));
  
      if (readCount > 0) {
        for (int i = 0;i<readCount;i++) {               
          TransmitByteFastNew(buf[i]);
        }
      }
    }    
    
    if (padBytes>0) {
      for (int i=0;i<padBytes;i++) {    
        TransmitByteFastNew(0xEA); 
      }
    }   
    
    delay(10);
    DisableCartridge();

    Serial.println(F("Done"));
    
    #ifdef DEBUG   
    Serial.print(F("TIME:")); Serial.println(millis()-pressTime);    
    TransferInfo(transferLength, padBytes, transferPages);    
    #endif    
    
    } else {
      Serial.println(F("FILENOTFOUND!"));
    }
}

void ResetNoCartridge() {
  DisableCartridge();
  ResetC64();
}


long startTransfer = 0;

void ReceiveFile() {
  #ifdef DEBUG
  Serial.println(F("Receiving"));
  #endif
  startTransfer = millis();
  EndListening();
  EnableCartridge();
  ResetC64();  
  ResetIndex();
  delay(2000);  
  #ifdef DEBUG  
  Serial.println(F("Resetted"));  
  #endif  
  unsigned int receivedCount = 0;
  unsigned int dataLength = 0;
  unsigned char low = 0;  
  unsigned char high = 0;  
  int endCondition = 0;
  
  while (receivedCount<4) {
    //if ((millis() - startTransfer) > 10000) break;
    if (Serial.available() > 0) {
      if ((millis() - startTransfer) > 10000) break;
      unsigned char data=Serial.read();    
      if (receivedCount == 0) {
        dataLength = data;
      } else if (receivedCount == 1) {
        dataLength = data * 256 + dataLength;
      } else if (receivedCount == 2) {
        low = data;
      } else if (receivedCount == 3) {
        high = data;
      }
      receivedCount++;
    }
  }

  Serial.println(F("HEAD"));  
  
  long transferLength = dataLength - 2;
  long padBytes = (transferLength%256==0) ? 0 : 256 - transferLength%256; 
  byte transferPages = (byte)(transferLength/256 + (padBytes>0 ? 1 : 0));  
  
  TransmitByteSlow(low);
  TransmitByteSlow(high);
  TransmitByteSlow(transferPages); 
  TransmitByteSlow(0x00);   
  receivedCount = 0;
  
  while (receivedCount<transferLength) {
    //if ((millis() - startTransfer) > 10000) break;
    
    if (Serial.available() > 0) {    
      //if ((millis() - startTransfer) > 10000) break;     
      unsigned char data=Serial.read();    
      TransmitByteFastNew(data); 
      receivedCount++;      
    }
  }
  
  Serial.println(F("RCVD"));   
  
  if ((millis() - startTransfer) < 10000) {
    if (padBytes>0) {
      for (int i=0;i<padBytes;i++) {    
        TransmitByteFastNew(0xEA); 
      }
    }  
  }
  delay(10);
  DisableCartridge();
  Serial.println(F("OK"));    
  #ifdef DEBUG 
  Serial.print(F("DAT LEN : "));Serial.println(dataLength);
    TransferInfo(transferLength, padBytes, transferPages);    
  #endif    
}

#ifdef DEBUG 
void dump() {
  Serial.print(F("Index is : ")); Serial.println(index);Serial.println();
  for (int i = 0;i<8;i++) {
    Serial.println(timeDifArray[i]);
  }
}
#endif

void clearReceived() {
  irqInit = 0;
  receivedByte = 0;
  timeDifference = 0;
  index = 0;  
}



void loop() {
    
  if (!digitalRead(SEL) && state == stateNone) {
    state = statePressed;
    pressTime = millis();
  }
  
  if (digitalRead(SEL) && state == statePressed) {
    state = stateReleased;          
    elapsed = millis() - pressTime;
    if (elapsed >2000) {
      SaveBootOption();
    } else if (elapsed >500) {
      ResetNoCartridge();
      cartridgeState = stateBoot;      
    } else {
      TransferMenu();
      cartridgeState = stateMenu;
    }
  }
  
  if (state == stateReleased) {
    if ( (millis() - pressTime)>1500) {
      state = stateNone;
      elapsed = 0;
      pressTime = 0;
    }
  }
    
    while (Serial.available() > 0) {
        char data=(char)Serial.read();
        switch(data) {
            case '1' : ReceiveFile(); break;
            case '2' : TransferMenu(); break;                                    
            case '3' : ResetC64(); break;
            case '4' : ResetNoCartridge(); break;
     
            #ifdef DEBUG        
            case '6' : dump(); break;            
            #endif
        }
    }

  if (irqInit) {
    if (received) {
      mask = 128;
      receivedByte = 0;
      for (int i=7;i>=0;i--) {
         if (timeDifArray[i]<15) {
           receivedByte =  receivedByte | mask;
           mask = mask>>1;
         } else if (timeDifArray[i]<25) {
           mask = mask>>1;           
         } else {
           clearReceived();
         }
      } 
      
      #ifdef DEBUG
      Serial.print(F("SEL:")); Serial.println(receivedByte);
      #endif
      EndListening();
      
      // If this is true then this is a special command
      if (receivedByte & 0x40) {
        if (receivedByte ==  0x43) {
            #ifdef DEBUG
            Serial.println(F("Next"));
            #endif
            //Next command
            delay(10);
            TransferDirectoryNext();
            cartridgeState = stateMenu;            
        }  else if (receivedByte == 0x41) {
            #ifdef DEBUG
            Serial.println(F("Previous"));
            #endif
            //Previous command
            delay(10);            
            TransferDirectoryPrevious();
            cartridgeState = stateMenu;                        
        }
      } else {
        //This is a load request
        if (receivedByte!=0) {
          receivedByte = receivedByte>>1;          
          InvokeSelected(receivedByte-1);  
          cartridgeState = stateGame;                      
        } else {
          clearReceived();          
        }
      }
    }
  }
    
}

unsigned char InitEprom() {
  if (EEPROM.read(0) != 0xCA || EEPROM.read(1) != 0xFE) {
    EEPROM.write(0, 0xCA);
    EEPROM.write(1, 0xFE);
    EEPROM.write(2, stateBoot);    
    return 0;
  } else {
    return  1;
  }
}

void SaveBootOption() {  
  if (cartridgeState == stateGame) 
  {        
    #ifdef DEBUG
    Serial.println(F("Boot Game!"));        
    #endif
    //DumpState();    
    dirFunc.InitSerialize();
    EEPROM.write(2, stateGame);    
    EEPROM.write(3, currentIndex);        
    unsigned char length = dirFunc.Serialize();
    for (unsigned char i = 0;i<length;i++) {
      EEPROM.write(4+i, dirFunc.Serialize());
    }
  } else if (cartridgeState == stateMenu) {
    #ifdef DEBUG    
    Serial.println(F("Boot menu!"));            
    #endif
    //EEPROM.write(2, stateMenu); 
    EEPROM.write(2, stateBoot);      //Menüye autoboot özelliğini kaldırıyorum.
  } else if (cartridgeState == stateBoot) {
    #ifdef DEBUG
    Serial.println(F("No autoboot"));                
    #endif
    EEPROM.write(2, stateBoot);
  }
}


void RestoreBootOption() {
  unsigned char option = EEPROM.read(2);
  
  if (option == stateMenu) {
    #ifdef DEBUG    
    Serial.println(F("Booting menu!"));    
    #endif
    TransferMenu();
  } else if (option == stateGame) {
    #ifdef DEBUG
    Serial.println(F("Booting game!"));    
    #endif
    dirFunc.InitSerialize();
    currentIndex = EEPROM.read(3);
    unsigned char length = dirFunc.Deserialize(0);
    for (unsigned char i = 0;i<length;i++) {
      unsigned char readValue = EEPROM.read(4+i);
      dirFunc.Deserialize(readValue);      
    }    
    
    //DumpState();
    
    dirFunc.ToRoot();  
  
    dirFunc.ChangeToSavedDirectory();
    dirFunc.Prepare();
    InvokeSelected(dirFunc.GetSelected());
  } 
}

/*
void DumpState() {
  Serial.print(F("Sel : ")); Serial.println(dirFunc.GetSelected());
  Serial.print(F("Top: ")); Serial.println(dirFunc.stack.top);
  Serial.print(F("It.count : ")); Serial.println(dirFunc.stack.itemCount);
  Serial.print(F("Count : ")); Serial.println(dirFunc.count);
  Serial.print(F("Items : "));  
  for (int i = 0;i<10;i++) {
    Serial.println(dirFunc.stack.itemArray[i]);
  }
  int number = 0;
  for (int i = 0;i<STACK_SIZE;i++) {
    number = number + dirFunc.stack.charBuffer[i];
  }
  
  Serial.print(F("Stack : "));  Serial.println(number);

}

*/

