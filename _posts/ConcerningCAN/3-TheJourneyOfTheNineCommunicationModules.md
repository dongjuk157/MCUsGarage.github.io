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

CAN IF 는 데이터 길이가 CAN IF에서 보낼 수 있는 길이(classic can 8, can fd 64)보다 작거나 같을 때 사용되고, CAN TP 는 CAN IF에서 보낼 수 있는 데이터 길이보다 클 때 사용된다.
- 다른 통신 모듈들도 비슷한 흐름을 가진다.

1. Transfer Data
   - ASW - RTE - COM - PduR - CAN TP - CAN IF - CAN Driver - Physical layer
2. Receive Data
   - Physical layer - CAN Driver - CAN IF - CAN TP - PduR - COM - RTE - ASW


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

CAN bus 트랜시버 드라이버는 ECU의 CAN 트랜시버를 동작시켜 ECU의 현재 상태와 버스 상태를 맞추는 역할을 한다.
트랜시버는 주로 마이컴 포트의 논리적 신호를 버스에 맞게 전기 레벨(특정 전압), 전류, 타이밍으로 변환시키는 장치이다.

트랜시버는 다음 기능을 지원한다.
- HS CAN, LS CAN, CAN FD를 지원. SAE J2411(single-wire can)은 지원하지 않음
- 전기 오작동 감지
- 버스를 통한 전원 공급 제어 및 wakeup 지원
- SBC(System Basis Chip)과의 통합

트랜시버 wakeup 발생 원인 (누가 요청했는지 저장 가능)
1. BUS: 버스가 wakeup을 유발함
2. Internally: 드라이버에 대한 소프트웨어 요청으로 인해 발생함 
3. Sleep: 슬립 모드에 있고 웨이크업이 발생하지 않음

### 3.4.2. Remarks to the CAN Bus Transceiver Driver

다양한 트랜시버가 있으므로 모든 기능에 대해서 지원하기 어려움. 적용 가능한 인터페이스와 동작만을 명세할 예정.
- 적어도 버스 트랜시버 기능의 "사용자"가 버스에 독립적이도록 명세함. 재사용 할 수 있도록
- 주로 AUTOSAR NM 이나 AUTOSAR Communication Manager 가 사용자임

1. 추가기능 미지원
   - 일부 CAN Trcv는 자체 테스트나 진단을 위한 기능을 제공함. 하지만 AUTOSAR는 이러한 기능을 일반적으로 요구하지 않음. 
   - 즉, 저렴한 트랜시버도 사용할수 있음.
2. 일반 API 불허 
   - IOControl() 같은 general and open(개방형) API를 허용하지 않음
3. SBC  
   - SBC 에는 CAN Trcv 외에 전원 제어 및 안전 관련한 기능이 포함된 하드웨어가 추가 되어있음
   - AUTOSAR 에서는 각 하드웨어 장치에 대해 별도의 인터페이스(관리/드라이버/핸들러)가 필요하지만 SBC 내부의 여러 기능을 독립적으로 처리하는 것은 어려움
   - 따라서 AUTOSAR 준수 ECU에서 SBC를 사용하려면 각각의 도메인의 모든 API를 포함하는 전문화된 매니저/드라이버/핸들러를 사용해야함



### 3.4.3. CAN Driver (CAN)
#### Functional Requirements

[SRS_Can_01036] The CAN Driver shall support Standard Identifier and Extended Identifier
[SRS_Can_01037] The CAN driver shall allow the static configuration of the hardware reception filter
[SRS_Can_01038] The bit timing of each CAN Controller shall be configurable
[SRS_Can_01039] Hardware Object Handles shall be provided for the CAN Interface in the static configuration file.
[SRS_Can_01058] shall be configurable whether Multiplex Transmission is used
[SRS_Can_01062] Each event for each CAN Controller shall be configurable to be detected by polling or by an interrupt
[SRS_Can_01135] It shall be possible to configure one or several TX Hardware Objects

[SRS_Can_01041] The CAN Driver shall implement an interface for initialization
[SRS_Can_01042] The CAN Driver shall support dynamic selection of configuration sets

[SRS_Can_01043] The CAN Driver shall provide a service to enable/disable interrupts of the CAN Controller.
[SRS_Can_01059] The CAN Driver shall guarantee data consistency of received L-PDUs
[SRS_Can_01045] The CAN Driver shall offer a reception indication service.
[SRS_Can_01049] The CAN Driver shall provide a dynamic transmission request service
[SRS_Can_01051] The CAN Driver shall provide a transmission confirmation service
[SRS_Can_01053] The CAN Driver shall provide a service to change the CAN controller mode.
[SRS_Can_01054] The CAN Driver shall provide a notification for controller wake-up events
[SRS_Can_01122] The CAN driver shall support the situation where a wakeup by bus occurs during the same time the transition to standby/sleep is in progress
[SRS_Can_01132] The CAN driver shall be able to detect notification events message object specific by CAN-Interrupt and polling
[SRS_Can_01134] The CAN Driver shall support multiplexed transmission
[SRS_Can_01147] The CAN Driver shall not support remote frames
[SRS_Can_01161] The CAN Driver shall support CAN FD
[SRS_Can_02001] The CAN Driver shall support CAN XL
[SRS_Can_01167] The CAN Driver shall provide a function to return the current CAN controller error state
[SRS_Can_01170] The CAN Driver shall provide a function to return the current CAN controller Rx and Tx error counters

[SRS_Can_01166] The CAN Driver shall implement an interface for de-initialization

[SRS_Can_01055] CAN Driver shall provide a notification for bus-off state
[SRS_Can_01060] The CAN driver shall not recover from bus-off automatically

#### Non-Functional Requirements
[SRS_Can_01033] The CAN Driver shall fulfill the general requirements for Basic Software Modules as specified in AUTOSAR_SRS_SPAL
[SRS_Can_01034] The CAN Driver shall offer a Hardware independent interface.
[SRS_Can_01035] The CAN Driver shall support multiple CAN controllers of the same CAN hardware unit 


### 3.4.4. CAN Interface(Hardware Abstraction) (CANIF)
#### Functional Requirements

#### Non-Functional Requirements

### 3.4.5. CAN State Manager (CANSM)
#### Functional Requirements

#### Non-Functional Requirements

### 3.4.6. Transport Layer CAN (CANTP)
#### Functional Requirements

#### Non-Functional Requirements

### 3.4.7. CAN Bus Transceiver Driver (CAN TRCV)
#### Functional Requirements

#### Non-Functional Requirements

### 3.4.8. CAN Driver and Interface together 

#### Non-Functional Requirements





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