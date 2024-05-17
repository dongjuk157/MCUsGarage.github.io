# 3. The Journey of the Nine Communication Modules

## 3.1. Standards - AUTOSAR Classic Platform 

[AUTOSAR-Classic-Platform-link](https://www.autosar.org/standards/classic-platform)

ASW(Application SW), RTE(Runtime Environment), BSW(Basic SW) 으로 이루어진 아키텍처

ASW: HW에 종속되지 않는 소프트웨어. SWC(Software Component)를 사용해서 컴포넌트 단위로 재사용, 재활용할수 있음.

RTE: ASW와 BSW를 분리하기 위한 층
- SWC들 사이의 데이터를 전달할 때 사용됨.(인터페이스 등)
- BSW 서비스 제공(OS 스케줄링, 이벤트 처리, 메모리, 진단 서비스 등)

BSW: HW에 종속적인 소프트웨어. OS, 센서 등을 포함함. 
1. Service Layer: BSW 중 가장 상위 계층. BSW의 다양한 기능을 서비스 형태로 제공함.
2. ECU Abstraction Layer(EAL): ECU 수준으로 추상화된 계층. 하드웨어에 종속적이지 않은 일정한 인터페이스를 제공함.
3. Microcontroller Abstraction Layer(MCAL): BSW 중 가장 하위 계층이며 HW에 의존적인 계층. microcontroller의 내외부 장치들과 연결된 메모리에 직접 접근 가능함.
4. Complex Device Driver(CDD): 특정 계층(Service, EAL, MCAL)에 매핑되지 않아 Microcontroller 에서 RTE까지 직접 구현해야함. AUTOSAR 표준에 정의 되지 않은 기능이 포함됨. (타이밍 관련)

Current Release
- AUTOSAR Classic Release R23-11 
- 해당 버전을 기준으로 작성한다. 

## 3.2. What is AUTOSAR Communication Stack(COM STACK)

- COM: Service Layer. 신호 수준의 액세스와 프로토콜(CAN, LIN, 등)과 관계 없이 하위 계층에 대한 PDU 수준 액세스를 제공하는 역할. Transmitter에선 PDU를 압축하고 Reciever에선 PDU를 압축 해제함.
- PDUR: Protocol Data Unit Router. Service Layer이고 COM 보다 하위에 있음. PDU를 특정 인터페이스 모듈로 라우팅함. PDU 레벨의 게이트 웨이로도 사용됨(다른 버스 인터페이스 모듈 간 전송).
- BUS TP: Transport Protocol. 페이로드가 8바이트를 초과하는 메세지를 분할하고 flow control(흐름 제어)를 통해 메세지를 전송하며, 수신기에서 분할된 메세지를 재조립하는 기능을 수행함.
- BUS Interface: ECU abstraction Layer. HAL(Hardware Abstraction Layer)과 Service Layer 간의 인터페이스를 제공함. 전송 요청, 전송 확인, 수신 표시, 컨트롤러 모드 제어 및 PDU 모드 제어와 같은 서비스를 담당함. 
- BUS Drivers: 
  - External Driver: Transceiver의 액세스를 제공함. (하드웨어 독립적인 인터페이스 제공)
  - Internal Driver: 실제 하드웨어 드라이버의 액세스를 제공함. (하드웨어 독립적인 인터페이스 제공)
- BUS SM: State Manager. 버스에 대한 제어흐름 구현. HAL 과 System Service Layer와 상호작용함.
- BUS NM: Network  Manager. 네트워크의 정상 작동(Normal)과 버스 절전 모드(Bus-Sleep) 사이의 전환을 조정함.

## 3.2.1 Transfer/Receive Data on CAN Flow



## 3.3. How To Read Documents

### 3.3.1. Reading Order in this document

1. 요구사항 및 해석
2. 명세 및 해석 
3. 예제 코드?

### 3.3.2. What is the difference between Requirements and Sepcification

Requirement (요구사항):
- 시스템이 달성해야 할 기능, 성능, 특성 등을 기술한 것
- 주로 사용자의 관점에서 정의되며, 시스템이 제공해야 할 기능과 특성을 명시
- "무엇을" 해야 하는지에 대해 초점을 맞춤
   
Specification (명세):
- 요구사항을 구체적으로 구현하는 방법을 기술한 것
- 시스템의 구체적인 설계와 구현 방법을 상세하게 명시함
- "어떻게" 요구사항을 구현할지 대해 초점을 맞춤


## 3.4. Requirements on CAN
[AUTOSAR-SRS-CAN](https://www.autosar.org/fileadmin/standards/R23-11/CP/AUTOSAR_CP_SRS_CAN.pdf)

### 3.4.1. Functional Overview
The CAN bus transceiver driver is responsible to handle the CAN transceivers on an ECU according to the expected state of the bus specific NM in relation to the current state of the whole ECU.
The transceiver is a hardware device, which mainly transforms the logical on/off signal values of the µC ports to the bus compliant electrical levels, currents and timings.
Within an automotive environment there are mainly three different CAN physics used. These physics are ISO11898 for high-speed CAN (up to 1Mbd), ISO11519 for low-speed CAN (up to 125kBd). Both are regarded in AUTOSAR, whereas SAE J2411 for single-wire CAN is not. CAN FD utilizes the same CAN physic as it is used for high-speed CAN but provide faster transmission rates.
In addition, the transceivers are often able to detect electrical malfunctions like wiring issues, ground offsets or transmission of too long dominant signals. Depending on the interface they flag the detected error summarized by a single port pin or very detailed via SPI.
Some transceivers also support power supply control and wakeup via the bus. A lot of different wakeup/sleep and power supply concepts are available on the market with focus to best-cost optimized solution for a given task.
Latest developments are so called SystemBasisChips (SBC) where not only the CAN and/or LIN transceivers but also power-supply control and advanced watchdogs are implemented in one housing and are controlled via one interface (typically an SPI).
A typical CAN transceiver is the TJA1054 for a low-speed CAN bus. The same state transition model is also used in TJA1041 (high-speed CAN with support for wakeup via CAN) and could be transferred also to a lot of other products on the market.

Transceiver Wakeup Reason
 The transceiver driver is able to store the local view on who has requested the wakeup: bus or software.

Bus: The bus has caused the wakeup.
Internally: The wakeup has been caused by a software request to the driver.
Sleep: The transceiver is in operation mode sleep and no wakeup has been occurred.


CAN 버스 트랜시버 드라이버는 전체 ECU의 현재 상태와 관련하여 특정 버스 NM의 예상 상태에 따라 ECU의 CAN 트랜시버를 처리하는 역할을 합니다.
트랜시버는 주로 µC 포트의 논리적 온/오프 신호 값을 버스 호환 전기 레벨, 전류 및 타이밍으로 변환하는 하드웨어 장치입니다.
자동차 환경에는 주로 세 가지 서로 다른 CAN 물리학이 사용됩니다. 이러한 물리학은 고속 CAN(최대 1Mbd)의 경우 ISO11898, 저속 CAN(최대 125kBd)의 경우 ISO11519입니다. 둘 다 AUTOSAR에서는 간주되지만 단일 와이어 CAN용 SAE J2411은 그렇지 않습니다. CAN FD는 고속 CAN에 사용되는 것과 동일한 CAN 물리학을 활용하지만 더 빠른 전송 속도를 제공합니다.
또한 트랜시버는 배선 문제, 접지 오프셋 또는 너무 긴 주요 신호 전송과 같은 전기적 오작동을 감지할 수 있는 경우가 많습니다. 인터페이스에 따라 감지된 오류를 단일 포트 핀으로 요약하거나 SPI를 통해 매우 자세히 표시합니다.
일부 트랜시버는 버스를 통한 전원 공급 제어 및 웨이크업도 지원합니다. 특정 작업에 대해 가장 비용이 최적화된 솔루션에 초점을 맞춘 다양한 웨이크업/슬립 및 전원 공급 장치 개념이 시장에 나와 있습니다.
최신 개발은 CAN 및/또는 LIN 트랜시버뿐만 아니라 전원 공급 장치 제어 및 고급 감시 기능이 하나의 하우징에 구현되고 하나의 인터페이스(일반적으로 SPI)를 통해 제어되는 SBC(SystemBasisChips)라고 합니다.
일반적인 CAN 트랜시버는 저속 CAN 버스용 TJA1054입니다. 동일한 상태 전이 모델은 TJA1041(CAN을 통한 웨이크업을 지원하는 고속 CAN)에도 사용되며 시중의 다른 많은 제품에도 전송할 수 있습니다.

트랜시버 웨이크업 이유
  트랜시버 드라이버는 웨이크업을 요청한 사람(버스 또는 소프트웨어)에 대한 로컬 보기를 저장할 수 있습니다.

버스: 버스가 깨우기를 유발했습니다.
내부적으로: 드라이버에 대한 소프트웨어 요청으로 인해 웨이크업이 발생했습니다.
슬립(Sleep): 무전기가 슬립 작동 모드에 있고 웨이크업이 발생하지 않았습니다.


## 3.. CAN Drivier
Communication Drivers(MCAL)

[AUTOSAR-SWS-CANDriver](https://autosar.org/fileadmin/standards/R23-11/CP/AUTOSAR_CP_SWS_CANDriver.pdf)

## 3.. CAN Transceiver Driver (CanTrcv)
Communication Hardware Abstraction(EAL)

[Specification of CAN Transceiver Driver]()

## 3.. CAN Interface (CanIf)
Communication Hardware Abstraction(EAL)

[Specification of CAN Interface]()

## 3.7. CAN Transport Layer (CANTP)
Communication Services

[Specification of CAN Transport Layer]()

## 3.8. CAN State Manager (CANSM)
Communication Services

[Specification of CAN State Manager]()

## 3.9. CAN Network Management Interface (CANNM)
Communication Services

[Specification of CAN Network Management]()

## 3.10. Requirements on Communication

## 3.11. Communication (Com)
Communication Services

[Specification of Communication]()

## 3.12. PDU Router (PduR)
Communication Services

[Specification of PDU Router]()


cf) I-PDU Multiplexer (IPDU)
- Specification of I-PDU Multiplexer
- Requirements on I-PDU Multiplexer
-> 얘가 더 중요한거같은데?


## 3.13. Others
COM based Transformer(ComXf): Communication Services
- Requirements on Transformer
- Specification of COM Based Transformer
CAN XL Driver
- Specification of CAN XL Driver
CAN XL Transceiver Driver
- Specification of CAN XL Transcevier Driver
TTCAN Driver
- Requirements on TTCAN
- Specification of TTCAN Driver