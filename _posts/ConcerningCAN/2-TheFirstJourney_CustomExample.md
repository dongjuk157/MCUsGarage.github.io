# 2. The First Journey
Communication with CAN

## 2.1. CAN Communication using TC275 Lite Kit

AURIX Development Studio 에 있는 CAN example 을 참고해서 실제 CAN 통신을 할 것이다.

### 2.1.1. 준비사항 
1. Windows 10 컴퓨터(노트북)
2. AURIX Development Studio - [how-to-setup](2024-03-14-HowToSetUpAURIXDevelopmentStudio.html)
3. TC275 Lite Kit & User Manual [link](https://www.infineon.com/dgdl/Infineon-AURIX_TC275_Lite_Kit-UserManual-v01_02-EN.pdf?fileId=5546d46272e49d2a017305871f9464ab)
4. TC27x User Manaul [link](https://www.infineon.com/dgdl/Infineon-TC27x_D-step-UM-v02_02-EN.pdf?fileId=5546d46269bda8df0169ca09b44623ed)
5. TC27x Data Sheet [link](https://www.infineon.com/dgdl/Infineon-TC27xDC-DataSheet-v01_00-EN.pdf?fileId=5546d462694c98b4016953972c57046a)
6. TC275 iLLD User Manual [link](https://www.infineon.com/cms/en/product/gated-document/tc27d-illd-um-1-0-1-16-0-8ac78c8c8779172a0187e6944d6c160b/)

## 2.2. Send CAN Messages (Loop-Back mode)

### 2.2.1. Create CAN Node for Tx

### 2.2.2. Create CAN Message Object for Tx

### 2.2.3. Check Transmitting

## 2.3. Receive CAN Messages (Loop-Back mode)

### 2.3.1. Create CAN Node for Rx

### 2.3.2. Create CAN Message Object for Rx

### 2.3.3. Check Receiving

## 2.4. Send & receive CAN FD Message (Loop-Back mode)

### 2.4.1. Create CAN FD Nodes(Tx, Rx)

### 2.4.2. Create CAN Message Objects(Tx, Rx)

### 2.4.3. Check Tx, Rx 

## 2.5. Send & Receive Long Messages with CAN-TP

CAN node와 CAN FD node는 2.2 부터 2.4 에서 만든 코드를 사용한다.

### 2.5.1. Create CAN TP Interface (1) Single Frame
### 2.5.2. Create CAN TP Interface (2) First Frame
### 2.5.3. Create CAN TP Interface (3) Consecutive Frame
### 2.5.4. Create CAN TP Interface (4) Flow Control

### 2.5.5. Check Tx, Rx 

## 2.6. Message Filtering
필터링에 관한 내용 설명

### 2.6.1. Create 1 Rx Node for Full CAN

### 2.6.2. Create 1 Rx Node for Basic CAN

### 2.6.1. Create 1 Tx Node

### 2.6.2. Check Tx, Rx.

## 2.7. Implement External Communication 

### 2.7.1. Use Another TC275 Litekit

### 2.7.2. Use Raspberry Pi & CAN HAT(RS485)

## 2.8. Collision Data

### 2.8.1. Create 2 Tx Node, 1 Rx Node

### 2.8.2. Check & Analyze

### 2.8.3. Change Priority of Messages

## 2.9. RX FIFO

## 2.10. TX FIFO

## 2.11. Gateway with TX FIFO

## 2.12. Error Handling (Bus off)