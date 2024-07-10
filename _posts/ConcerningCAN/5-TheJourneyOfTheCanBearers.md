# 5. The Journey of the CAN-bearers

이 챕터에서는 CAN 프로토콜과 같이 사용하는 상위 레이어에 대해서 설명한다.

CAN network는 Physical Layer와 Data Link Layer에 대한 내용이므로 상위 레이어는 다른 프로토콜을 섞어서 사용한다.

## 5.2.

ISO-TP - ISO 15765-2(자동차 진단용 전송 프로토콜) 
물리적인 CAN의 길이(CAN 8Byte, CANFD 64Byte)보다 더 긴 메세지를 보내야하는 경우 사용한다.
- 페이로드 데이터 크기를 최대 4095 Byte까지 확장한다.

ISO TP Frame Types

1. Single Frame(SF)
2. First Frame(FF)
3. Consecutive Frame(CF)
4. Flow Control Frame(FC)

## 5.1. Diagnostics
- DCM(Diagnostic Communication Manager)
- DEM(Diagnostic Event Manager)
- UDS on CAN

### UDS on CAN

#### What is UDS
Unified diagnostic services (UDS)

자동차 전자 제어 장치 (ECU) 에 사용되는 진단 통신 프로토콜이다.

OSI 모델의 5, 7번째 계층을 사용한다.

Request 기반 프로토콜이므로 클라이언트-서버 관계를 갖는다.
- 테스터(진단기)가 클라이언트이고 ECU가 서버가 된다. 
- 테스터가 필요한 기능을 요청하면 서버는 서비스를 제공하고 응답(긍정, 부정)을 준다.

Request Frame

CAN ID / Protocol Control Info(PCI) / Service Identifier(SID) / Sub Function Byte / DID(Data Identifier, Request Data Parameters)

Response Frame

Positive
- ..
  
Negative
- CAN ID / Protocol Control Info(PCI) / Negative Response(SID): 0x7F / Rejected SID / NRC(Negative Response Code)


#### ISO Spec
Road vehicles / Unified diagnostic services (UDS)
- ISO 14229-1: Part 1: Application layer
- ISO 14229-2: Part 2: Session layer services
- ISO 14229-3: Part 3: Unified diagnostic services on CAN implementation (UDSonCAN)

Road vehicles / Diagnostic communication over Controller Area Network (DoCAN)
- ISO 15765-1: Part 1: General information and use case definition -> 사용안함
- ISO 15765-2: Part 2: Transport protocol and network layer services
- ISO 15765-3: Part 3: Implementation of unified diagnostic services (UDS on CAN) -> 사용안함. ISO 14229-3 으로 흡수

HKMC - UDS
- ES 95486-02


## 5.2. Calibration
- XCP on CAN

### XCP

#### What is XCP

Universal Measurement and Calibration Protocol 

https://cdn.vector.com/cms/content/application-areas/ecu-calibration/xcp/XCP_Book_V1.5_EN.pdf
https://cdn.vector.com/cms/content/application-areas/ecu-calibration/xcp/XCP_ReferenceBook_V2.0_KO.pdf



## 5.3. Others

EnergyBus - CiA 454 및 IEC 61851-3(배터리-충전기 통신)

SAE J1939(버스 및 트럭용 차량 내 네트워크)

SAE J2284(승용차용 차량 내 네트워크)

GMLAN - 제너럴 모터스(제너럴 모터스용)
