# 2. The First Journey
Communication with CAN

## 2.1. CAN Communication using TC275 Lite Kit

AURIX Development Studio 에 있는 CAN example 을 사용해서 실제 CAN 통신을 해 볼 것이다.

### 2.1.1. 준비사항 
1. Windows 10 컴퓨터(노트북)
2. AURIX Development Studio - [how-to-setup](2024-03-14-HowToSetUpAURIXDevelopmentStudio.html)
3. TC275 Lite Kit & User Manual [link](https://www.infineon.com/dgdl/Infineon-AURIX_TC275_Lite_Kit-UserManual-v01_02-EN.pdf?fileId=5546d46272e49d2a017305871f9464ab)
4. TC27x User Manaul [link](https://www.infineon.com/dgdl/Infineon-TC27x_D-step-UM-v02_02-EN.pdf?fileId=5546d46269bda8df0169ca09b44623ed)
5. TC27x Data Sheet [link](https://www.infineon.com/dgdl/Infineon-TC27xDC-DataSheet-v01_00-EN.pdf?fileId=5546d462694c98b4016953972c57046a)
6. TC275 iLLD User Manual [link](https://www.infineon.com/cms/en/product/gated-document/tc27d-illd-um-1-0-1-16-0-8ac78c8c8779172a0187e6944d6c160b/)

## 2.2. Analysis of the examples

[AURIX Expert Training](https://www.infineon.com/cms/en/product/promopages/aurix-expert-training/)

Example

### 2.2.1. MULTICAN
MULTICAN_1_KIT_TC275_LK-TR ([Link](https://www.infineon.com/dgdl/Infineon-AURIX_MULTICAN_1_KIT_TC275_LK-TR-Training-v01_00-EN.pdf?fileId=5546d4627a0b0c7b017a5868238f4cba))

- TC275 Lite Kit에 CAN Node를 두 개 만들고, 루프백 모드를 사용해서 서로 통신한다.
- 예제 동작
  1. Node 0 sends data to Node 1
  2. if the transmission is successful, an interrupt service routine occurs that turns on LED1. 
  3. Node 1 receives data from Node 0
  4. if reception is successful, an interrupt service routine occurs. The ISR compares the tx data and rx data and turn on LED2 if they are equal

#### 2.2.1.1. core0_main

<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
int core0_main(void)
{
    IfxCpu_enableInterrupts();

    /* !!WATCHDOG0 AND SAFETY WATCHDOG ARE DISABLED HERE!!
     * Enable the watchdogs and service them periodically if it is required
     */
    IfxScuWdt_disableCpuWatchdog(IfxScuWdt_getCpuWatchdogPassword());
    IfxScuWdt_disableSafetyWatchdog(IfxScuWdt_getSafetyWatchdogPassword());

    /* Wait for CPU sync event */
    IfxCpu_emitEvent(&g_cpuSyncEvent);
    IfxCpu_waitEvent(&g_cpuSyncEvent, 1);

    /* Application code: initialization of MULTICAN, LEDs and the transmission of the CAN message */
    initMultican();
    initLed();
    transmitCanMessage();

    while(1)
    {
    }
    return (1);
}
```
</div>
</details>

- 전역 인터럽트 활성화 - CAN TX, RX 될때 Interrupt Service Routine을 사용해야하므로 인터럽트를 활성화한다.
- WDG 비활성화 - 추후 작성
  - cpu WDG
  - Safety WDG
- Core 동기화
  - core0, core1, core2 모두 emit할때까지 기다리고 동기화가 맞춰지면 이후 코드 실행하는 듯 하다. 
- CAN 예제 구동시 필요한 코드
  - CAN 모듈 초기화
  - LED 모듈 초기화
  - 메세지 전송
- (꺼지지 않도록) 무한 루프


#### 2.2.1.2. Initialize MultiCAN Module

<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
// 주석 부분 일정 생략
void initMultican(void)
{
    /* ==========================================================================================
     * CAN module configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_initModuleConfig(&g_multican.canConfig, &MODULE_CAN);

    g_multican.canConfig.nodePointer[TX_INTERRUPT_SRC_ID].priority = ISR_PRIORITY_CAN_TX;
    g_multican.canConfig.nodePointer[RX_INTERRUPT_SRC_ID].priority = ISR_PRIORITY_CAN_RX;

    IfxMultican_Can_initModule(&g_multican.can, &g_multican.canConfig);

    /* ==========================================================================================
     * Source CAN node configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_Node_initConfig(&g_multican.canNodeConfig, &g_multican.can);

    g_multican.canNodeConfig.loopBackMode = TRUE;
    g_multican.canNodeConfig.nodeId = IfxMultican_NodeId_0;

    IfxMultican_Can_Node_init(&g_multican.canSrcNode, &g_multican.canNodeConfig);

    /* ==========================================================================================
     * Destination CAN node configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_Node_initConfig(&g_multican.canNodeConfig, &g_multican.can);

    g_multican.canNodeConfig.loopBackMode = TRUE;
    g_multican.canNodeConfig.nodeId = IfxMultican_NodeId_1;

    IfxMultican_Can_Node_init(&g_multican.canDstNode, &g_multican.canNodeConfig);

    /* ==========================================================================================
     * Source message object configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_MsgObj_initConfig(&g_multican.canMsgObjConfig, &g_multican.canSrcNode);

    g_multican.canMsgObjConfig.msgObjId = SRC_MESSAGE_OBJECT_ID;
    g_multican.canMsgObjConfig.messageId = CAN_MESSAGE_ID;
    g_multican.canMsgObjConfig.frame = IfxMultican_Frame_transmit;
    g_multican.canMsgObjConfig.txInterrupt.enabled = TRUE;
    g_multican.canMsgObjConfig.txInterrupt.srcId = TX_INTERRUPT_SRC_ID;

    IfxMultican_Can_MsgObj_init(&g_multican.canSrcMsgObj, &g_multican.canMsgObjConfig);

    /* ==========================================================================================
     * Destination message object configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_MsgObj_initConfig(&g_multican.canMsgObjConfig, &g_multican.canDstNode);

    g_multican.canMsgObjConfig.msgObjId = DST_MESSAGE_OBJECT_ID;
    g_multican.canMsgObjConfig.messageId = CAN_MESSAGE_ID;
    g_multican.canMsgObjConfig.frame = IfxMultican_Frame_receive;
    g_multican.canMsgObjConfig.rxInterrupt.enabled = TRUE;
    g_multican.canMsgObjConfig.rxInterrupt.srcId = RX_INTERRUPT_SRC_ID;

    IfxMultican_Can_MsgObj_init(&g_multican.canDstMsgObj, &g_multican.canMsgObjConfig);
}
``` 
</div>
</details>

아래 함수는 각각 기존 디폴트 값에 user config값을 업데이트하기 위한 함수이다. 
- CAN module configuration and initialization
  - IfxMultican_Can_initModuleConfig
  - IfxMultican_Can_initModule
  - 여기선 CAN node의 인터럽트 우선순위를 설정한다.
- Source/Destination CAN node configuration and initialization
  - IfxMultican_Can_Node_initConfig 
  - IfxMultican_Can_Node_init
  - 여기선 각 CAN node의 루프백 모드와 실제 node ID(src: node0, dst: node1)를 설정한다.
- Source/Destination message object configuration and initialization
  - IfxMultican_Can_MsgObj_initConfig 
  - IfxMultican_Can_MsgObj_init
  - 여기선 Message Object 와 관련된 설정을 한다.
    - Message Object ID 정의
    - Arbitration 단계에서 사용되는 CAN 메시지 ID 정의
    - 메시지 객체 타입 정의(Tx/Rx) 
    - 인터럽트 생성 활성화(Tx와 Rx의 인터럽트 노드 포인터는 달라야함)

위의 함수들은 다음과 같은 순서를 통해 업데이트한다.
1. IfxMultican_Can_**init*Config** 함수를 통해 구조체를 초기화하고 해당 모듈의 기본 설정값을 가져온다(load).
2. 설정 값을 수정한다. (modify)
3. IfxMultican_Can_**init*** 함수를 통해 변경된 설정 값으로 실제 초기화한다(initialize).
   - 해당 API를 살펴보면 어떤 레지스터가 바뀌는지 파악할 수 있다. 

ex) Can Node1에 대해서 초기화하는 과정을 살략보면 다음과 같다.
1. CAN Node 구조체(`&g_multican.canNodeConfig`)를 초기화하고 내부에서 아래를 포함한 값으로 초기화 한다. (이후는 길어서 생략)
   - `Can_Node_initConfig(&g_multican.canNodeConfig, &g_multican.can)` 
     - `config->module = mcan->mcan;`
     - `config->nodeId = IfxMultican_NodeId_0;`
     - `config->loopBackMode = FALSE;`
2. 설정 값을 수정한다.
   - 해당 노드는 루프백 모드를 사용하고 destination으로 사용할 노드이므로 아래처럼 수정한다. 
   - `g_multican.canNodeConfig.loopBackMode = TRUE;`
   - `g_multican.canNodeConfig.nodeId = IfxMultican_NodeId_1;`
3. 수정한 값(`&g_multican.canNodeConfig`)으로 실제 노드(`&g_multican.canDstNode`)를 업데이트한다.
   - `Can_Node_init(&g_multican.canDstNode, &g_multican.canNodeConfig)`  
   - 여기서 실제 레지스터 값을 변경한다.



#### 2.2.1.3. Initialize LED Modele
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
void initLed(void)
{
    /* ======================================================================
     * Configuration of the pins connected to the LEDs:
     * ======================================================================
     */
    g_led.led1.port      = &MODULE_P00;
    g_led.led1.pinIndex  = PIN5;
    g_led.led1.mode      = IfxPort_OutputIdx_general;
    g_led.led1.padDriver = IfxPort_PadDriver_cmosAutomotiveSpeed1;

    g_led.led2.port      = &MODULE_P00;
    g_led.led2.pinIndex  = PIN6;
    g_led.led2.mode      = IfxPort_OutputIdx_general;
    g_led.led2.padDriver = IfxPort_PadDriver_cmosAutomotiveSpeed1;

    /* Initialize the pins connected to LEDs to level "HIGH"; will keep the LEDs turned off as default state */
    IfxPort_setPinHigh(g_led.led1.port, g_led.led1.pinIndex);
    IfxPort_setPinHigh(g_led.led2.port, g_led.led2.pinIndex);

    /* Set the pin input/output mode for both pins connected to the LEDs */
    IfxPort_setPinModeOutput(g_led.led1.port, g_led.led1.pinIndex, IfxPort_OutputMode_pushPull, g_led.led1.mode);
    IfxPort_setPinModeOutput(g_led.led2.port, g_led.led2.pinIndex, IfxPort_OutputMode_pushPull, g_led.led2.mode);

    /* Set the pad driver mode for both pins connected to the LEDs */
    IfxPort_setPinPadDriver(g_led.led1.port, g_led.led1.pinIndex, g_led.led1.padDriver);
    IfxPort_setPinPadDriver(g_led.led2.port, g_led.led2.pinIndex, g_led.led2.padDriver);
}
```
</div>
</details>

해당함수는 LED를 키고 끌 수 있도록 설정하기 위한 함수이다.
- AppLedType 인 전역변수 g_led를 생성하고 그 안에 LED1, LED2를 각각 설정한다.
   - LED1: P00.5, output, paddriver-cmos
   - LED2: P00.6, output, paddriver-cmos
   - 해당 핀들은 TC275 Lite Kit의 LED에 연결된 포트이다.
- 다음 함수들을 사용해서 LED를 초기화한다.
- IfxPort_setPinHigh 를 통해서 핀상태를 HIGH로 만든다.
   - TC275 LK의 LED의 기본 설정은 Active Low이므로 핀 상태를 HIGH만들어서 OFF 상태를 유지한다.
- IfxPort_setPinModeOutput 를 통해서 핀 모드를 설정한다.
   - output mode: LED와 연결되므로 GPIO는 Output으로 되어야함
   - push-pull mode: 내부 회로를 통해 출력을 결정함. 전원(VEXT)은 3.3V을 사용함
- IfxPort_setPinPadDriver 를통해서 핀의 pad driver를 설정한다.

<details>
<summary><strong>LED in EVB usermanual(Click)</strong></summary>
<div markdown="1">

![EVBoard-UM-p13-LED](../assets/postsAssets/ConcerningCAN/Table3_AURIX_Pin_Mapping_for_User_LEDs.png)
![EVBoard-UM-p20-03-power-a-connector-LED](../assets/postsAssets/ConcerningCAN/Buttons_and_LEDs.png)

</div>
</details>

#### 2.2.1.4. Transmit CAN Message
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
/* Function to initialize both TX and RX messages with the default data values.
 * After initialization of the messages, the TX message will be transmitted.
 */
void transmitCanMessage(void)
{
    /* Define the content of the data to be transmitted */
    const uint32 dataLow  = 0xC0CAC01A;
    const uint32 dataHigh = 0xBA5EBA11;

    /* Invalidation of the RX message */
    IfxMultican_Message_init(&g_multican.rxMsg,
                             INVALID_ID_VALUE,
                             INVALID_DATA_VALUE,
                             INVALID_DATA_VALUE,
                             g_multican.canMsgObjConfig.control.messageLen);

    /* Initialization of the TX message */
    IfxMultican_Message_init(&g_multican.txMsg,
                             g_multican.canMsgObjConfig.messageId,
                             dataLow,
                             dataHigh,
                             g_multican.canMsgObjConfig.control.messageLen);

    /* Send the CAN message with the previously defined TX message content */
    while( IfxMultican_Status_notSentBusy ==
           IfxMultican_Can_MsgObj_sendMessage(&g_multican.canSrcMsgObj, &g_multican.txMsg) )
    {
    }
}
```
</div>
</details>

실제로 CAN 노드를 통해서 데이터를 보내는 함수이다.
- RX는 메세지를 받아야하므로 보낼 메세지가 아닌 값으로 초기화한다.
   - id: `0xFFFFFFFF`
   - data:`0xDEADBEEF`
- TX는 보낼 메세지로 초기화 한다.
   - messageId: `0x777`
   - dataLow: `0xC0CAC01A`(cocacola)
   - dataHigh: `0xBA5EBA11`(baseball)
- 아래 함수를 통해서 CAN 메세지를 보낸다
   - `IfxMultican_Can_MsgObj_sendMessage(&g_multican.canSrcMsgObj, &g_multican.txMsg)`
   - msg object를 확인해서 보낼 메세지가 있으면 메세지를 보낸다. 
   - 메세지를 보낼때까지(CAN BUS가 IDLE이 아니면) 송신을 계속 시도한다.


#### 2.2.1.5. Interrupt Service Routines for TX
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
IFX_INTERRUPT(canIsrTxHandler, 0, ISR_PRIORITY_CAN_TX);

void canIsrTxHandler(void)
{
    /* Just to indicate that the CAN message has been transmitted by turning on LED1 */
    IfxPort_setPinLow(g_led.led1.port, g_led.led1.pinIndex);
}
```
</div>
</details>

송신부의 Interrupt handler이다.
- 데이터가 송신될때 인터럽트 루틴이 발생해서 해당 함수가 불린다.
- 인터럽트 서비스 루틴을 등록하기 위해선 다음 매크로를 사용한다.
   - `IFX_INTERRUPT(isr, vectabNum, priority)`
   - 해당 매크로는 
   - isr: 인터럽트가 생기면 불리는 콜백함수
   - vectabNum: Vector table number
   - priority: 우선순위
      - 인터럽트가 여러번 불릴 때 처리순서를 위한 우선순위
      - 같은 순위로 만들수 없으므로 조금더 중요한 걸 높이 올림
      - tx, rx의 우선순위는 tx를 높게 해놨음.
- 해당 핸들러가 불리면 GPIO 핀을 LOW로 내려서 LED1을 킴(active low)

#### 2.2.1.6. Interrupt Service Routines for RX
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
IFX_INTERRUPT(canIsrRxHandler, 0, ISR_PRIORITY_CAN_RX);

void canIsrRxHandler(void)
{
    IfxMultican_Status readStatus;

    /* Read the received CAN message and store the status of the operation */
    readStatus = IfxMultican_Can_MsgObj_readMessage(&g_multican.canDstMsgObj, &g_multican.rxMsg);

    /* If no new data has been received, report an error */
    if( !( readStatus & IfxMultican_Status_newData ) )
    {
        while(1)
        {
        }
    }

    /* If new data has been received but with one message lost, report an error */
    if( readStatus == IfxMultican_Status_newDataButOneLost )
    {
        while(1)
        {
        }
    }

    /* Finally, check if the received data matches with the transmitted one */
    if( ( g_multican.rxMsg.data[0] == g_multican.txMsg.data[0] ) &&
        ( g_multican.rxMsg.data[1] == g_multican.txMsg.data[1] ) &&
        ( g_multican.rxMsg.id == g_multican.txMsg.id ) )
    {
        /* Turn on the LED2 to indicate correctness of the received message */
        IfxPort_setPinLow(g_led.led2.port, g_led.led2.pinIndex);
    }
}
```
</div>
</details>

수신부의 Interrupt handler이다.
- 메세지가 수신되면 해당 핸들러가 불리고 다음을 수행함
   - 수신된 메세지를 읽고 state를 저장함.
   - 해당 데이터가 새로운 데이터인지 메세지가 손실되었는지 확인함.
   - 정상 데이터라면 보낸 메세지와 받은 메세지가 같은지 확인하고 id도 같은지 확인함
   - 다 같은 경우에만 GPIO 핀을 LOW로 내려서 LED2을 킴(active low)
- 실제로도 cocacola, baseball이 나오는지 확인 **(결과 사진 필요)**

### 2.2.2. MULTICAN in Flexible Data-Rate
MULTICAN_FD_1_KIT_TC275_LK-TR ([Link](https://www.infineon.com/dgdl/Infineon-AURIX_MULTICAN_FD_1_KIT_TC275_LK-TR-Training-v01_00-EN.pdf?fileId=5546d4627a0b0c7b017a586832ba4cbd))

- TC275 Lite Kit에 CAN Node를 CANFD 모드로 두 개 만들고, 루프백 모드를 사용해서 서로 통신한다. 
- 예제 동작
  1. Node 0 sends data to Node 1
  2. if the transmission and reception are successful, an interrupt is generated.
  3. In the interrupt service routine, read the reception data and compare tx, rx data. 
  4. If not errors detected, turn on LED

예제 "2.2.1.MULTICAN"과 겹치는 코드(비슷한 코드)는 스킵

#### 2.2.2.1. core0_main
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c

uint8 g_currentCanFdUseCase = 0;
IfxCpu_syncEvent g_cpuSyncEvent = 0;

int core0_main(void)
{
    /* skip, similar code  */

    /* Application code: initialization of MULTICAN, LED, transmission and verification of the CAN messages */
    initMultican();
    initLed();

    for(g_currentCanFdUseCase = 0; g_currentCanFdUseCase < NUMBER_OF_CAN_FD_CASES; g_currentCanFdUseCase++)
    {
        transmitCanMessage();
        verifyCanMessage();

        if(g_status != CanCommunicationStatus_Success)
        {
            break;
        }
    }

    /* If there was no error, turn on the LED to indicate correctness of the received messages */
    if(g_status == CanCommunicationStatus_Success)
    {
        IfxPort_setPinLow(g_led1.port, g_led1.pinIndex);
    }

    /* skip, similar code */
}
```
</div>
</details>

- 전역 인터럽트 활성화
- WDG 비활성화 
- Core 동기화
- CAN 예제 구동시 필요한 코드
  - CAN 모듈 초기화: CAN FD 설정
  - LED 모듈 초기화: LED1(pin00.5) 설정
  - 메세지 전송 및 검증(4회 반복)
  - 모든 메세지가 제대로 전송 된 경우 LED ON
- (꺼지지 않도록) 무한 루프

#### 2.2.2.2. Initialize MultiCAN Module
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
#define STANDARD_MESSAGE_ID_1 0x444     /* Message ID that is used in arbitration phase */
#define STANDARD_MESSAGE_ID_2 0x777     /* Message ID that is used in arbitration phase */
#define EXTENDED_MESSAGE_ID_1 0x1234567 /* Message ID that is used in arbitration phase */
#define EXTENDED_MESSAGE_ID_2 0xAABBCCD /* Message ID that is used in arbitration phase */

const canMessageObjectConfigType    g_messageObjectConf[NUMBER_OF_CAN_FD_CASES] =
   {
      /* message ID / Extended Frame / message Length / Fast bitrate */
      { STANDARD_MESSAGE_ID_1, FALSE, IfxMultican_DataLengthCode_8,  FALSE },
      { EXTENDED_MESSAGE_ID_1, TRUE,  IfxMultican_DataLengthCode_8,  TRUE  },
      { STANDARD_MESSAGE_ID_2, FALSE, IfxMultican_DataLengthCode_32, FALSE },
      { EXTENDED_MESSAGE_ID_2, TRUE,  IfxMultican_DataLengthCode_64, TRUE  }
   };

void initMultican(void)
{
    uint8 currentCanMessageObject;
    /* ==========================================================================================
     * CAN module configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_initModuleConfig(&g_multican.canConfig, &MODULE_CAN);

    g_multican.canConfig.nodePointer[RX_INTERRUPT_SRC_ID].priority = ISR_PRIORITY_CAN_RX;

    IfxMultican_Can_initModule(&g_multican.can, &g_multican.canConfig);

    /* ==========================================================================================
     * Common CAN node configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_Node_initConfig(&g_multican.canNodeConfig, &g_multican.can);

    g_multican.canNodeConfig.loopBackMode = TRUE;
    g_multican.canNodeConfig.flexibleDataRate = TRUE;

    g_multican.canNodeConfig.fdConfig.nominalBaudrate = 500000;
    g_multican.canNodeConfig.fdConfig.nominalSamplePoint = 8000;
    g_multican.canNodeConfig.fdConfig.nominalSynchJumpWidth = 2000;
    g_multican.canNodeConfig.fdConfig.fastBaudrate = 2000000;
    g_multican.canNodeConfig.fdConfig.fastSamplePoint = 7000;
    g_multican.canNodeConfig.fdConfig.fastSynchJumpWidth = 2000;
    g_multican.canNodeConfig.fdConfig.loopDelayOffset = 0;

    /* ==========================================================================================
     * CAN node 0 configuration and initialization:
     * =========================================================================================
     */
    g_multican.canNodeConfig.nodeId = IfxMultican_NodeId_0;

    IfxMultican_Can_Node_init(&g_multican.canNode0, &g_multican.canNodeConfig);

    /* ==========================================================================================
     * CAN node 1 configuration and initialization:
     * ==========================================================================================
     */
    g_multican.canNodeConfig.nodeId = IfxMultican_NodeId_1;

    IfxMultican_Can_Node_init(&g_multican.canNode1, &g_multican.canNodeConfig);

    /* ==========================================================================================
     * Source standard message objects configuration and initialization:
     * ==========================================================================================
     * These CAN message objects are assigned to CAN Node 0
     * ==========================================================================================
     */
    IfxMultican_Can_MsgObj_initConfig(&g_multican.canMsgObjConfig, &g_multican.canNode0);

    g_multican.canMsgObjConfig.frame = IfxMultican_Frame_transmit;
    g_multican.canMsgObjConfig.control.matchingId = TRUE;

    for(currentCanMessageObject = 0; currentCanMessageObject < NUMBER_OF_CAN_FD_CASES; currentCanMessageObject++)
    {
        g_multican.canMsgObjConfig.msgObjId = (IfxMultican_MsgObjId)currentCanMessageObject;
        g_multican.canMsgObjConfig.messageId = g_messageObjectConf[currentCanMessageObject].messageId;
        g_multican.canMsgObjConfig.control.extendedFrame = g_messageObjectConf[currentCanMessageObject].extendedFrame;
        g_multican.canMsgObjConfig.control.topMsgObjId = (2 * currentCanMessageObject) + SRC_EXTENDED_MO_OFFSET; 
        g_multican.canMsgObjConfig.control.bottomMsgObjId = g_multican.canMsgObjConfig.control.topMsgObjId + 1;

        g_multican.canMsgObjConfig.control.messageLen = g_messageObjectConf[currentCanMessageObject].messageLen;
        g_multican.canMsgObjConfig.control.fastBitRate = g_messageObjectConf[currentCanMessageObject].fastBitRate;

        IfxMultican_Can_MsgObj_init(&g_multican.canSrcMsgObj[currentCanMessageObject], &g_multican.canMsgObjConfig);
    }

    /* ===========================================================================================
     * Destination standard message objects configuration and initialization:
     * ===========================================================================================
     * These CAN message objects are assigned to CAN Node 1
     * ===========================================================================================
     */
    IfxMultican_Can_MsgObj_initConfig(&g_multican.canMsgObjConfig, &g_multican.canNode1);

    g_multican.canMsgObjConfig.frame = IfxMultican_Frame_receive;
    g_multican.canMsgObjConfig.control.matchingId = TRUE;
    g_multican.canMsgObjConfig.rxInterrupt.enabled = TRUE;
    g_multican.canMsgObjConfig.rxInterrupt.srcId = RX_INTERRUPT_SRC_ID;

    for(currentCanMessageObject = 0; currentCanMessageObject < NUMBER_OF_CAN_FD_CASES; currentCanMessageObject++)
    {
        g_multican.canMsgObjConfig.msgObjId = (IfxMultican_MsgObjId)(currentCanMessageObject + DST_MO_OFFSET);
        g_multican.canMsgObjConfig.messageId = g_messageObjectConf[currentCanMessageObject].messageId;
        g_multican.canMsgObjConfig.control.extendedFrame = g_messageObjectConf[currentCanMessageObject].extendedFrame;
        g_multican.canMsgObjConfig.control.topMsgObjId = (2 * currentCanMessageObject) + DST_EXTENDED_MO_OFFSET; 
        g_multican.canMsgObjConfig.control.bottomMsgObjId = g_multican.canMsgObjConfig.control.topMsgObjId + 1;

        g_multican.canMsgObjConfig.control.messageLen = g_messageObjectConf[currentCanMessageObject].messageLen;

        IfxMultican_Can_MsgObj_init(&g_multican.canDstMsgObj[currentCanMessageObject], &g_multican.canMsgObjConfig);
    }
}

```
</div>
</details>

- CAN Node RX 인터럽트 우선 순위 설정
  - Rx 인터럽트만 사용함.  
- CAN node 설정(Node0, Node1)
  - loop back 모드 설정
  - Flexible Data rate 모드 설정
    - CAN FD 관련 설정 
    - nominal: 500kbps, 80% sample point, 20% sync jump width 
    - fast: 2000kbps, 70% sample point, 20% sync jump width 
    - loop delay offset: 0
- CAN Message Object 설정 
  - 일치하는 IDE 만 데이터 프레임을 허가함(`control.matchingId = TRUE;`)
  - CAN Node 0(Tx)의 Message Object 설정 (메세지 4개)
    - Message Object ID
    - Message ID
    - standard/extanded frame
    - Top, Bottom Message Object Id
    - Message Length
    - fast Bit Rate
  - CAN Node 1(Rx)의 Message Object 설정 (메세지 4개)
    - 인터럽트 활성화 및 인터럽트 노드 포인터 정의
      - `rxInterrupt.enabled = TRUE;`
      - `rxInterrupt.srcId = RX_INTERRUPT_SRC_ID;`
    - Message Object ID
    - Message ID
    - standard/extanded frame
    - Top, Bottom Message Object Id
    - Message Length

#### 2.2.2.3. Transmit CAN Message 
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
void transmitCanMessage(void)
{
    uint8 currentDataPayloadByte;

    /* Invalidation of the RX message */
    IfxMultican_Message_longFrameInit(
        &g_multican.rxMsg,
        INVALID_ID_VALUE,
        INVALID_LENGTH_VALUE,
        INVALID_FAST_BITRATE_VALUE);
    
    /* Invalidation of the RX message data content */
    memset((void *)(&g_multican.rxData[0]), INVALID_RX_DATA_VALUE, MAXIMUM_CAN_FD_DATA_PAYLOAD);

    /* Invalidation of the TX message data content */
    memset((void *)(&g_multican.txData[0]), INVALID_TX_DATA_VALUE, MAXIMUM_CAN_FD_DATA_PAYLOAD);
    
    /* Initialization of the TX message data content */
    for(currentDataPayloadByte = 0; 
        currentDataPayloadByte < g_dlcLookUpTable[g_messageObjectConf[g_currentCanFdUseCase].messageLen];
        currentDataPayloadByte++)
    {
        /* Each CAN message data payload byte is initialized in the following format:
         *  
         * |          7 6          |       5 4 3 2 1 0      |
         * | g_currentCanFdUseCase | currentDataPayloadByte |
         * |       ( 0 - 3 )       |       ( 0 - 63 )       |
         */
        g_multican.txData[currentDataPayloadByte] = 
            (g_currentCanFdUseCase << TX_DATA_INIT_SHIFT_OFFSET) |
            currentDataPayloadByte;
    }

    if(g_messageObjectConf[g_currentCanFdUseCase].messageLen > IfxMultican_DataLengthCode_8)
    {
        /* Initialization of the TX message (long frame) */
        IfxMultican_Message_longFrameInit(
            &g_multican.txMsg,
            g_messageObjectConf[g_currentCanFdUseCase].messageId,
            g_messageObjectConf[g_currentCanFdUseCase].messageLen,
            g_messageObjectConf[g_currentCanFdUseCase].fastBitRate);

        /* Send the CAN message with the previously defined TX message content */
        while(IfxMultican_Status_notSentBusy ==
            IfxMultican_Can_MsgObj_sendLongFrame(
               &g_multican.canSrcMsgObj[g_currentCanFdUseCase],
               &g_multican.txMsg,
               (uint32*)&g_multican.txData));
        {
        }
    }
    else
    {
        /* Initialization of the TX message (standard frame) */
        IfxMultican_Message_init(
            &g_multican.txMsg,
            g_messageObjectConf[g_currentCanFdUseCase].messageId,
            *(uint32*)&g_multican.txData[0],
            *(uint32*)&g_multican.txData[4],
            g_messageObjectConf[g_currentCanFdUseCase].messageLen);

        /* Send the CAN message with the previously defined TX message content */
        while(IfxMultican_Status_notSentBusy ==
            IfxMultican_Can_MsgObj_sendMessage(
                &g_multican.canSrcMsgObj[g_currentCanFdUseCase],
                &g_multican.txMsg));
        {
        }
    }

    /* Wait until previously transmitted data has been received in the destination message object */
    while(g_isrRxCount == g_currentCanFdUseCase)
    {
    }
}

```
</div>
</details>

- 메세지 당 한번씩 호출
  - `g_messageObjectConf`
    - `{ STANDARD_MESSAGE_ID_1, FALSE, IfxMultican_DataLengthCode_8,  FALSE }`
    - `{ EXTENDED_MESSAGE_ID_1, TRUE,  IfxMultican_DataLengthCode_8,  TRUE  }`
    - `{ STANDARD_MESSAGE_ID_2, FALSE, IfxMultican_DataLengthCode_32, FALSE }`
    - `{ EXTENDED_MESSAGE_ID_2, TRUE,  IfxMultican_DataLengthCode_64, TRUE  }` 
- CAN Message 초기화
  - Rx message data: invalid data
  - Tx message data: long frame data
    - message data content의 모든 바이트를 하나하나 설정
- CAN BUS가 Not busy 일때 메세지 송신
  - DLC8 초과면 Extended Frame으로 송신(`IfxMultican_Can_MsgObj_sendLongFrame`)
  - DLC8 이하면 Standard frame으로 송신(`IfxMultican_Can_MsgObj_sendMessage`)
- 메세지가 수신될까지(Rx ISR이 불릴때까지) 대기

#### 2.2.2.4. Interrupt Service Routines for RX
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
IFX_INTERRUPT(canIsrRxHandler, 0, ISR_PRIORITY_CAN_RX);

void canIsrRxHandler(void)
{
    IfxMultican_Status readStatus;

    if(g_messageObjectConf[g_isrRxCount].messageLen > IfxMultican_DataLengthCode_8)
    {
        /* Read the received long frame CAN message and store the status of the operation */
        readStatus = IfxMultican_MsgObj_readLongFrame(
            g_multican.canDstMsgObj[g_isrRxCount].node->mcan,
            g_multican.canDstMsgObj[g_isrRxCount].msgObjId,
            &g_multican.rxMsg,
            (uint32*)&g_multican.rxData);
    }
    else
    {
        /* Read the received standard frame CAN message and store the status of the operation */
        readStatus = IfxMultican_Can_MsgObj_readMessage(
            &g_multican.canDstMsgObj[g_isrRxCount], 
            &g_multican.rxMsg);

        memcpy((void *)(
            &g_multican.rxData[0]),
            (void *)(&g_multican.rxMsg.data[0]),
            IfxMultican_DataLengthCode_8);
    }

    /* If no new data has been received, report an error */
    if(!( readStatus & IfxMultican_Status_newData ))
    {
        g_status = CanCommunicationStatus_Error_noNewDataReceived;
    }

    /* If new data has been received but with one message lost, report an error */
    if(readStatus == IfxMultican_Status_newDataButOneLost)
    {
        g_status = CanCommunicationStatus_Error_newDataButOneLost;
    }

    /* If there was no error, increment the counter to indicate the number of successfully received CAN messages */
    if (g_status == CanCommunicationStatus_Success)
    {
        g_isrRxCount++;
    }
}

```
</div>
</details>

- `IFX_INTERRUPT` 로 우선순위 및 ISR 콜백함수 설정 
- 수신된 메세지를 읽고 오류가 없는지 확인함
  - Extended frame(`IfxMultican_MsgObj_readLongFrame`)
  - Standard frame(`IfxMultican_Can_MsgObj_readMessage`)
  - 오류는 새로운 데이터가 없는 경우, 새로운 데이터는 있으나 손실된 경우가 있다.
- 에러가 없으면 카운터(`g_isrRxCount`)를 증가시킴


<details>
<summary><strong>IfxMultican.c 와 IfxMultican_Can.c의 함수(API) 차이점 (Click)</strong></summary>
<div markdown="1">

<table>
  <tr>
    <th>  </th>
    <th> in IfxMultican.c</th>
    <th> in IfxMultican_Can.c</th>
  </tr>
  <tr>
    <td> Standard </td>
    <td> <img src="../../assets/postsAssets/ConcerningCAN/func_IfxMultican_MsgObj_readMessage.png" alt="func_IfxMultican_MsgObj_readMessage"/> </td>
    <td> <img src="../../assets/postsAssets/ConcerningCAN/func_IfxMultican_Can_MsgObj_readMessage.png" alt="func_IfxMultican_Can_MsgObj_readMessage"/> </td>
  </tr>
  <tr>
    <td> Extended </td>
    <td> <img src="../../assets/postsAssets/ConcerningCAN/func_IfxMultican_MsgObj_readLongFrame.png" alt="func_IfxMultican_Can_MsgObj_readMessage"/> </td>
    <td> <img src="../../assets/postsAssets/ConcerningCAN/func_IfxMultican_Can_MsgObj_readLongFrame.png" alt="func_IfxMultican_Can_MsgObj_readMessage"/> </td>
  </tr>
</table>

```c
IfxMultican_Status IfxMultican_Can_MsgObj_readMessage
(
   IfxMultican_Can_MsgObj *msgObj,
   IfxMultican_Message *msg
)
{
    IfxMultican_Status   status = IfxMultican_Status_ok;
    IfxMultican_MsgObjId objId;

    if (msgObj->msgObjCount > 1)
    {
        /* for FIFO message Objects */
        objId = msgObj->fifoPointer;
    }
    else
    {
        /* for standard message Objects */
        objId = msgObj->msgObjId;
    }

    Ifx_CAN_MO *hwObj = IfxMultican_MsgObj_getPointer(msgObj->node->mcan, objId);

    /* clear pending flag */
    IfxMultican_MsgObj_clearRxPending(hwObj);

    /* read the message object */
    status = IfxMultican_MsgObj_readMessage(hwObj, msg);

    /* if successfull: */
    if (status & IfxMultican_Status_newData)
    {
        if (msgObj->msgObjCount > 1)
        {
            /* set next message object(MOSTAT.PNEXT) of the current object as the next txFIFO slave object */
            msgObj->fifoPointer = IfxMultican_MsgObj_getBottomObjectPointer(hwObj);
        }
        else
        {}
    }

    return status;
}

```
- 내부 코드를 보면 다음과 같다. 
- 코드를 분석하면 Message Object 에 대해서 ID를 구하고 message object 데이터를 읽는걸 볼수 있다. 즉, `IfxMultican_Can` 에 있는 함수들은 `IfxMultican`의 함수를 사용해서 메세지를 읽는다. 어떤 함수를 사용하든 데이터를 읽을수 있다.
- 추가적으로, `IfxMultican_Can_MsgObj_readLongFrame`은 iLLD User manaul엔 등록되어있는데 실제 예제코드엔 들어있지 않다. 그러므로 `IfxMultican_MsgObj_readLongFrame`만 사용할수 있다.

</div>
</details>



#### 2.2.2.5. Verify Can Message
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
void verifyCanMessage(void)
{
    uint8 currentDataPayloadByte;

    /* Check if the received message ID does NOT match with the expected message ID.
     * If this is the case, an error should be reported.
     */
    if(g_multican.rxMsg.id != g_multican.txMsg.id)
    {
        g_status = CanCommunicationStatus_Error_notExpectedMessageId;
    }

    /* Check if the received message length does NOT match with the expected message length.
     * If this is the case, an error should be reported.
     */
    if(g_multican.rxMsg.lengthCode != g_multican.txMsg.lengthCode)
    {
        g_status = CanCommunicationStatus_Error_notExpectedLengthCode;
    }

    /* Check if the received fast bit rate bit does NOT match with the expected fast bit rate value.
     * If this is the case, an error should be reported.
     */
    if(g_multican.rxMsg.fastBitRate != g_multican.txMsg.fastBitRate)
    {
        g_status = CanCommunicationStatus_Error_notExpectedFastBitrateValue;
    }

    /* Finally, check if the received data does NOT match with the transmitted one.
     * If this is the case, an error should be reported. 
     *
     * Both "rxData" and "txData" arrays have the size of MAXIMUM_CAN_FD_DATA_PAYLOAD (64 bytes). Additionally, both of
     * the arrays are fully initialized so the possible incorrect number of transmitted bytes can be detected.
     * For this reason, the check is performed in two steps:
     *     - First "for" loop compares the valid expected data to the received data. The "currentDataPayloadByte"
     *       iterator variable is incremented to the number of bytes defined by the "g_multican.rxMsg.lengthCode"
     *       variable and can be either 8, 32, or 64 bytes. This value equals to the number of valid expected data bytes.
     *     - Second "for" loop checks the invalid data to make sure that the content has not been changed.
     *       The "currentDataPayloadByte" iterator variable is incremented from the current value of the variable
     *       (for this reason, the initialization part of the second "for" loop is omitted) to the
     *       MAXIMUM_CAN_FD_DATA_PAYLOAD (64 bytes) value.
     */
    for(currentDataPayloadByte = 0; 
        currentDataPayloadByte < g_dlcLookUpTable[g_multican.rxMsg.lengthCode];
        currentDataPayloadByte++)
    {
        if(g_multican.rxData[currentDataPayloadByte] != g_multican.txData[currentDataPayloadByte])
        {
            g_status = CanCommunicationStatus_Error_notExpectedData;
        }
    }

    for(/*...*/;
        currentDataPayloadByte < MAXIMUM_CAN_FD_DATA_PAYLOAD;
        currentDataPayloadByte++)
    {
        if(g_multican.rxData[currentDataPayloadByte] != INVALID_RX_DATA_VALUE)
        {
            g_status = CanCommunicationStatus_Error_notExpectedData;
        }
    }
}
```
</div>
</details>

- 실제 수신된 데이터가 송신한 데이터랑 같은지 검증함.
  - Message ID
  - Message Length
  - Fast bit rate bit value
  - Data
- 검증에 실패하면 각 단계별로 에러코드를 담아서 보냄
  - early return을 사용안해서 앞에서 검증 실패해도 뒷부분까지 다 검증하는듯하다.


### 2.2.3. MULTICAN using a Gateway with a TX FIFO
MULTICAN_GW_TX_FIFO_1_KIT_TC275_LK-TR ([Link](https://www.infineon.com/dgdl/Infineon-AURIX_MULTICAN_GW_TX_FIFO_1_KIT_TC275_LK-TR-Training-v01_00-EN.pdf?fileId=5546d4627a0b0c7b017a586843c04cc0))

![graphical-representation](../../assets/postsAssets/ConcerningCAN/multican_gw_tx_fifo_graphical_representation.png)

- TX FIFO 구조를 갖는 노드를 만들고, 게이트웨이(Gateway)를 사용해서 CAN BUS 간 데이터를 교환한다.
- 예제 동작
  1. Node 2에서 CAN BUS(A)로 메세지를 보낸다.(루프백모드일때 모든 노드가 CAN BUS에 접근할수 있음)
  2. Node 0이 전송된 메세지를 수신하면 게이트웨이를 통해 Node 1로 전송한다.
     - Node 1에 TX FIFO buffer Structure 정의함 
  3. Node 1은 게이트웨이를 통해 메세지가 수신되면 Node 3에 전송한다. (CAN BUS B)
  4. Node 3에서 데이터를 받으면 (Node 2에서) 전송한 메세지와 비교하고, 값이 같으면 LED를 킨다.
- 필요 지식
  - Gateway mode: CPU 개입없이 두개의 독립적인 CAN 버스 간 데이터 전송하는 것. 
    - 이번 예제에선 CAN BUS A의 데이터를 CAN BUS B로 전송함. 
  - FIFO Buffer structure: 여러 메세지를 수신했을때 들어온 순서대로 처리하는 것.
    - CPU load가 높은 경우 메세지 처리 시간이 충분하지 않아 모든 메세지를 처리하기 어려울수 있음. 이럴때 FIFO 구조를 사용해서 모든 메세지를 처리할수 있도록 함.

선행 예제들과 겹치는 코드(비슷한 코드)는 스킵

#### 2.2.3.1. core0_main
- 전역 인터럽트 활성화
- WDG 비활성화 
- Core 동기화
- CAN 예제 구동시 필요한 코드
  - CAN 모듈 초기화: CAN Tx Gateway 설정
  - LED 모듈 초기화: LED1(pin00.5) 설정
  - 메세지 전송
  - 메세지 검증
    - 메세지가 제대로 전송 된 경우 LED ON
- (꺼지지 않도록) 무한 루프

#### 2.2.3.2. Initialize MultiCAN Module
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
void initMultican(void)
{
    uint8 currentCanNode;

    /* ==========================================================================================
     * CAN module configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_initModuleConfig(&g_multican.canConfig, &MODULE_CAN);

    g_multican.canConfig.nodePointer[RX_INTERRUPT_SRC_ID].priority = ISR_PRIORITY_CAN_RX;

    IfxMultican_Can_initModule(&g_multican.can, &g_multican.canConfig);

    /* ==========================================================================================
     * Common CAN node configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_Node_initConfig(&g_multican.canNodeConfig, &g_multican.can);

    g_multican.canNodeConfig.loopBackMode = TRUE;

    for(currentCanNode = 0; currentCanNode < NUMBER_OF_CAN_NODES; currentCanNode++)
    {
        g_multican.canNodeConfig.nodeId = (IfxMultican_NodeId)currentCanNode;

        IfxMultican_Can_Node_init(&g_multican.canNode[currentCanNode], &g_multican.canNodeConfig);
    }

    /* ======================================================================
     * Gateway source message object configuration and initialization:
     * This CAN message object is assigned to CAN Node 0
     * ======================================================================
     */
    IfxMultican_Can_MsgObj_initConfig(&g_multican.canMsgObjConfig, &g_multican.canNode[0]);

    g_multican.canMsgObjConfig.msgObjId = GTW_SRC_MESSAGE_OBJECT_ID;
    g_multican.canMsgObjConfig.messageId = GTW_SRC_MESSAGE_ID;
    g_multican.canMsgObjConfig.msgObjCount = TX_FIFO_SIZE;
    g_multican.canMsgObjConfig.frame = IfxMultican_Frame_receive;
    g_multican.canMsgObjConfig.firstSlaveObjId = SLAVE_MESSAGE_OBJECT_ID;

    g_multican.canMsgObjConfig.gatewayTransfers = TRUE;
    g_multican.canMsgObjConfig.gatewayConfig.copyDataLengthCode = TRUE;
    g_multican.canMsgObjConfig.gatewayConfig.copyData = TRUE;
    g_multican.canMsgObjConfig.gatewayConfig.copyId = FALSE;
    g_multican.canMsgObjConfig.gatewayConfig.enableTransmit = TRUE;
    g_multican.canMsgObjConfig.gatewayConfig.gatewayDstObjId = SLAVE_MESSAGE_OBJECT_ID;

    IfxMultican_Can_MsgObj_init(&g_multican.canGtwSrcMsgObj, &g_multican.canMsgObjConfig);

    /* =====================================================================================
     * Gateway destination (implemented as TX FIFO object) configuration and initialization:
     * This CAN message object is assigned to CAN Node 1
     * =====================================================================================
     */
    IfxMultican_Can_MsgObj_initConfig(&g_multican.canMsgObjConfig, &g_multican.canNode[1]);

    g_multican.canMsgObjConfig.msgObjId = GTW_DST_MESSAGE_OBJECT_ID;
    g_multican.canMsgObjConfig.messageId = GTW_DST_MESSAGE_ID;
    g_multican.canMsgObjConfig.msgObjCount = TX_FIFO_SIZE;
    g_multican.canMsgObjConfig.frame = IfxMultican_Frame_transmit;
    g_multican.canMsgObjConfig.firstSlaveObjId = SLAVE_MESSAGE_OBJECT_ID;

    IfxMultican_Can_MsgObj_init(&g_multican.canGtwDstMsgObj, &g_multican.canMsgObjConfig);

    /* ==========================================================================
     * This CAN message object is assigned to CAN Node 2
     * ==========================================================================
     */
    IfxMultican_Can_MsgObj_initConfig(&g_multican.canMsgObjConfig, &g_multican.canNode[2]);

    g_multican.canMsgObjConfig.msgObjId = SRC_MESSAGE_OBJECT_ID;
    g_multican.canMsgObjConfig.messageId = SRC_MESSAGE_ID;
    g_multican.canMsgObjConfig.frame = IfxMultican_Frame_transmit;

    IfxMultican_Can_MsgObj_init(&g_multican.canSrcMsgObj, &g_multican.canMsgObjConfig);

    /* ==========================================================================
     * Destination standard message object configuration and initialization:
     * This CAN message object is assigned to CAN Node 3
     * ==========================================================================
     */
    IfxMultican_Can_MsgObj_initConfig(&g_multican.canMsgObjConfig, &g_multican.canNode[3]);

    g_multican.canMsgObjConfig.msgObjId = DST_MESSAGE_OBJECT_ID;
    g_multican.canMsgObjConfig.messageId = DST_MESSAGE_ID;
    g_multican.canMsgObjConfig.frame = IfxMultican_Frame_receive;
    g_multican.canMsgObjConfig.rxInterrupt.enabled = TRUE;
    g_multican.canMsgObjConfig.rxInterrupt.srcId = RX_INTERRUPT_SRC_ID;

    IfxMultican_Can_MsgObj_init(&g_multican.canDstMsgObj, &g_multican.canMsgObjConfig);
}

```
</div>
</details>

- CAN Node RX 인터럽트 우선순위 설정
- CAN Node 공통 설정: 루프백 모드 
- CAN Node 0의 Message Object 설정 및 gateway source 설정 
  - FIFO 개수 설정 (2개)
  - RX Message object 설정(CAN BUS로 들어오는 데이터를 받기 위함)
  - FIFO의 첫번째 slave object를 TX FIFO base object 다음 첫번째 메세지로 설정
  - 게이트웨이 전송 활성화(게이트웨이 소스 개체 정의)
  - 게이트웨이로 전송할 데이터 정의(id 빼고 복사해서 사용)
- CAN Node 1의 Message Object 설정 및 gateway destination 설정
  - FIFO로 받는 MO 설정
- CAN Node 2 설정: Tx Message Object
- CAN Node 3 설정: Rx Message Object 


#### 2.2.3.3. Transmit CAN Message
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
void transmitCanMessages(void)
{
    /* Invalidation of the RX messages */
    for(g_currentCanMessage = 0; g_currentCanMessage < NUMBER_OF_CAN_MESSAGES; g_currentCanMessage++)
    {
        IfxMultican_Message_init(&g_multican.rxMsg[g_currentCanMessage],
                                 INVALID_ID_VALUE,
                                 INVALID_DATA_VALUE,
                                 INVALID_DATA_VALUE,
                                 INVALID_LENGTH_VALUE);
    }

    for(g_currentCanMessage = 0; g_currentCanMessage < NUMBER_OF_CAN_MESSAGES; g_currentCanMessage++)
    {
        /* Initialization of the TX message */
        IfxMultican_Message_init(&g_multican.txMsg,
                                 SRC_MESSAGE_ID,
                                 ( g_canInitialMessageData[0] | g_currentCanMessage ),
                                 ( g_canInitialMessageData[1] | g_currentCanMessage ),
                                 g_multican.canMsgObjConfig.control.messageLen);

        /* Send the CAN message with the previously defined TX message content */
        while(IfxMultican_Status_notSentBusy ==
           IfxMultican_Can_MsgObj_sendMessage(&g_multican.canSrcMsgObj, &g_multican.txMsg))
        {
        }

        /* Wait until previously transmitted data has been received in the destination message object and no error has been detected. If the code execution stops at this point, check the "g_status" variable.
         */
        while(g_isrRxCount == g_currentCanMessage)
        {
        }
    }
}

```

</div>
</details>

- CAN Message 초기화
  - Rx message data: invalid data
  - Tx message data: long frame data
    - message data content의 모든 바이트를 하나하나 설정
- CAN BUS가 Not busy 일때 메세지 송신
  - DLC8 이하면 Standard frame으로 송신(`IfxMultican_Can_MsgObj_sendMessage`)
- 메세지가 수신될까지(Rx ISR이 불릴때까지) 대기

#### 2.2.3.4. Verify Can Message 

<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
void verifyCanMessages(void)
{
    Ifx_CAN_MO *hwObj;

    /* Get the pointer to the gateway source object. */
    hwObj = IfxMultican_MsgObj_getPointer(g_multican.can.mcan, GTW_SRC_MESSAGE_OBJECT_ID);

    /* Check if the CUR value does not match with the expected data in the gateway source object.
     * If this is the case, an error should be reported.
     */
    if(EXPECTED_CUR_POINTER_VALUE != hwObj->FGPR.B.CUR)
    {
        g_status = CanCommunicationStatus_Error_notExpectedFifoCurPointer;
    }

    /* Get the pointer to the gateway destination (TX FIFO base) object */
    hwObj = IfxMultican_MsgObj_getPointer(g_multican.can.mcan, GTW_DST_MESSAGE_OBJECT_ID);

    /* Check if the CUR value does not match with the expected data in the gateway destination object.
     * If this is the case, an error should be reported.
     */
    if(EXPECTED_CUR_POINTER_VALUE != hwObj->FGPR.B.CUR)
    {
        g_status = CanCommunicationStatus_Error_notExpectedFifoCurPointer;
    }

    for(g_currentCanMessage = 0; g_currentCanMessage < NUMBER_OF_CAN_MESSAGES; g_currentCanMessage++)
    {
        /* Check if the received message ID matches with the transmitted message ID.
         * If this is the case, an error should be reported. Source standard message object and destination
         * standard message object have different message ID configuration.
         */
        if(g_multican.rxMsg[g_currentCanMessage].id == SRC_MESSAGE_ID)
        {
            g_status = CanCommunicationStatus_Error_notExpectedMessageId;
            break;
        }

        /* Check if the received message length does NOT match with the expected message length.
         * If this is the case, an error should be reported.
         */
        if(g_multican.rxMsg[g_currentCanMessage].lengthCode != g_multican.canMsgObjConfig.control.messageLen)
        {
            g_status = CanCommunicationStatus_Error_notExpectedLengthCode;
            break;
        }

        /* Finally, check if a received data does NOT match with the transmitted one
         * If this is the case, an error should be reported.
         */
        if((g_multican.rxMsg[g_currentCanMessage].data[0] != (g_canInitialMessageData[0] | g_currentCanMessage)) ||
            (g_multican.rxMsg[g_currentCanMessage].data[1] != (g_canInitialMessageData[1] | g_currentCanMessage)))
        {
            g_status = CanCommunicationStatus_Error_notExpectedData;
            break;
        }
    }

    /* If there was no error, turn on the LED1 to indicate correctness of the received messages */
    if(g_status == CanCommunicationStatus_Success)
    {
        IfxPort_setPinLow(g_led1.port, g_led1.pinIndex);
    }
}

```

</div>
</details>

- 메세지를 수신한뒤 아래 확인
  - source, destination object 값 비교
  - Tx, Rx Message ID 비교 
  - Data Length 및 실제 데이터 값 비교 
- 다 일치하면 LED 점등. 하나라도 실패하면 에러 리턴(g_status)

### 2.2.4. MULTICAN using RX FIFO
MULTICAN_RX_FIFO_1_KIT_TC275_LK-TR ([Link](https://www.infineon.com/dgdl/Infineon-AURIX_MULTICAN_RX_FIFO_1_KIT_TC275_LK-TR-Training-v01_00-EN.pdf?fileId=5546d4627a0b0c7b017a586853b24cc3))

![rx-fifo-graphical-representation](../../assets/postsAssets/ConcerningCAN/multican_rx_fifo_graphical_representation.png)

- RX FIFO 구조를 만들고 노드간 데이터를 교환한다.
- 예제 동작
  1. Node 0 에서 데이터를 보낸다.
  2. Node 1은 RX FIFO에 전송된 메세지를 저장한다.
  3. FIFO가 임계값에 도달하면 ISR이 발생하고, 이때 CPU1이 ISR을 처리한다.
  4. ISR이 처리될때 수신된 CAN 메세지를 모두 읽고 전송된 메세지와 비교한다. 값이 같으면 LED를 킨다.
- 필요 지식
  - 멀티코어
  - RX FIFO

#### 2.2.4.1. core0_main

<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
IfxCpu_syncEvent g_cpuSyncEvent = 0;

int core0_main(void)
{
    IfxCpu_enableInterrupts();
    
    IfxScuWdt_disableCpuWatchdog(IfxScuWdt_getCpuWatchdogPassword());
    IfxScuWdt_disableSafetyWatchdog(IfxScuWdt_getSafetyWatchdogPassword());
    
    IfxCpu_emitEvent(&g_cpuSyncEvent);
    IfxCpu_waitEvent(&g_cpuSyncEvent, 1);
    
    initMultican();
    transmitCanMessages();

    while(1)
    {
    }
    return (1);
}

```
</div>
</details>

- 전역 인터럽트 활성화
- WDG 비활성화 
- Core 동기화
- CAN 예제 구동시 필요한 코드
  - CAN 모듈 초기화: CAN RX FIFO 설정
  - 메세지 전송
- (꺼지지 않도록) 무한 루프

#### 2.2.4.2. Initialize MultiCAN Module 

<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
void initMultican(void)
{
    Ifx_CAN_MO *hwObj;

    /* ==========================================================================================
     * CAN module configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_initModuleConfig(&g_multican.canConfig, &MODULE_CAN);

    g_multican.canConfig.nodePointer[OVERFLOW_INTERRUPT_SRC_ID].priority = ISR_PRIORITY_CAN_OVERFLOW;
    g_multican.canConfig.nodePointer[OVERFLOW_INTERRUPT_SRC_ID].typeOfService = ISR_PROVIDER_CAN_OVERFLOW;

    IfxMultican_Can_initModule(&g_multican.can, &g_multican.canConfig);

    /* ==========================================================================================
     * Common CAN node configuration and initialization:
     * ==========================================================================================
     */
    IfxMultican_Can_Node_initConfig(&g_multican.canNodeConfig, &g_multican.can);

    g_multican.canNodeConfig.loopBackMode = TRUE;

    /* ===================================================================
     * CAN node 0 configuration and initialization:
     * ===================================================================
     */
    g_multican.canNodeConfig.nodeId = IfxMultican_NodeId_0;

    IfxMultican_Can_Node_init(&g_multican.canNode0, &g_multican.canNodeConfig);

    /* ===================================================================
     * CAN node 1 configuration and initialization:
     * ===================================================================
    */
    g_multican.canNodeConfig.nodeId = IfxMultican_NodeId_1;

    IfxMultican_Can_Node_init(&g_multican.canNode1, &g_multican.canNodeConfig);

    /* ===================================================================
     * Source standard message object configuration and initialization:
     * This CAN message object is assigned to CAN Node 0
     * ===================================================================
     */
    IfxMultican_Can_MsgObj_initConfig(&g_multican.canMsgObjConfig, &g_multican.canNode0);

    g_multican.canMsgObjConfig.msgObjId = SRC_MESSAGE_OBJECT_ID;
    g_multican.canMsgObjConfig.messageId = CAN_MESSAGE_ID;
    g_multican.canMsgObjConfig.frame = IfxMultican_Frame_transmit;

    IfxMultican_Can_MsgObj_init(&g_multican.canSrcMsgObj, &g_multican.canMsgObjConfig);

    /* ===================================================================
     * RX FIFO structure configuration and initialization:
     * This CAN message object is assigned to CAN Node 1
     * ===================================================================
     */
    IfxMultican_Can_MsgObj_initConfig(&g_multican.canMsgObjConfig, &g_multican.canNode1);

    g_multican.canMsgObjConfig.msgObjId = RX_FIFO_BASE_OBJECT_ID;
    g_multican.canMsgObjConfig.messageId = CAN_MESSAGE_ID;
    g_multican.canMsgObjConfig.msgObjCount = RX_FIFO_SIZE;
    g_multican.canMsgObjConfig.frame = IfxMultican_Frame_receive;
    g_multican.canMsgObjConfig.firstSlaveObjId = SLAVE_MESSAGE_OBJECT_ID;

    IfxMultican_Can_MsgObj_init(&g_multican.canDstMsgObj, &g_multican.canMsgObjConfig);

    hwObj = IfxMultican_MsgObj_getPointer(g_multican.can.mcan, RX_FIFO_BASE_OBJECT_ID);
    IfxMultican_MsgObj_setOverflowInterrupt(hwObj, TRUE);
    IfxMultican_MsgObj_setTransmitInterruptNodePointer(hwObj, OVERFLOW_INTERRUPT_SRC_ID);
    IfxMultican_MsgObj_setSelectObjectPointer(hwObj, SLAVE_MESSAGE_OBJECT_ID);
}


```
</div>
</details>

- 인터럽트 우선순위 설정. 
  - overflow ISR
- 루프백 모드 설정
- Message Object 설정
- CAN Node 0: TX
  - RX FIFO Base object와 같은 CAN Message ID 로 설정 
- CAN Node 1: RX
  - FIFO 크기 3
- Overflow 인터럽트 활성화

#### 2.2.4.3. core1_main

<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
extern IfxCpu_syncEvent g_cpuSyncEvent;
boolean g_allMessagesReceived = FALSE;

int core1_main(void)
{
    IfxCpu_enableInterrupts();
    
    IfxScuWdt_disableCpuWatchdog(IfxScuWdt_getCpuWatchdogPassword());
    
    IfxCpu_emitEvent(&g_cpuSyncEvent);
    IfxCpu_waitEvent(&g_cpuSyncEvent, 1);

    initLed();

    while(!g_allMessagesReceived)
    {
    }
    verifyCanMessages();

    while(1)
    {
    }
    return (1);
}
```
</div>
</details>

- 전역 인터럽트 활성화
- WDG 비활성화 
- Core 동기화
- CAN 예제 구동시 필요한 코드
  - LED 모듈 초기화: LED1(pin00.5) 설정
  - 메세지 갯수 확인 
  - 메세지 검증
    - 메세지가 제대로 전송 된 경우 LED ON
- (꺼지지 않도록) 무한 루프

#### 2.2.4.4. Interrupt Service Routines for RX

<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
IFX_INTERRUPT(canIsrOverflowHandler, 1, ISR_PRIORITY_CAN_OVERFLOW);

void canIsrOverflowHandler(void)
{
    IfxMultican_Status readStatus;
    uint8 currentCanMessage;
    static volatile uint8 numOfReceivedMessages = 0;

    for(currentCanMessage = 0; currentCanMessage < RX_FIFO_SIZE; currentCanMessage++)
    {
        /* Read the received CAN message and store the status of the operation */
        readStatus = IfxMultican_Can_MsgObj_readMessage(&g_multican.canDstMsgObj, &g_multican.rxMsg[numOfReceivedMessages]);

        /* If no new data has been received, report an error */
        if(readStatus != IfxMultican_Status_newData)
        {
            g_status = CanCommunicationStatus_Error_noNewDataReceived;
        }

        /* If a new data has been received but one message was lost, report an error */
        if(readStatus == IfxMultican_Status_newDataButOneLost)
        {
            g_status = CanCommunicationStatus_Error_newDataButOneLost;
        }

        /* If there was no error, increment the counter to indicate the number of successfully received CAN messages */
        if (g_status == CanCommunicationStatus_Success)
        {
            numOfReceivedMessages++;

            if(numOfReceivedMessages == NUMBER_OF_RECEIVED_MESSAGES)
            {
                g_allMessagesReceived = TRUE;
            }
        }
    }
}
```
</div>
</details>

- overflow 인터럽트가 발생되면 해당 함수 실행
- FIFO 크기만큼 반복 수행
  - 메세지 읽고 작업상태 저장 
  - 수신한 데이터 없으면 에러 발생
  - 데이터는 수신되었지만 잃어버렸으면 에러 발생
- 모든 메세지 받았을 때 `g_allMessagesReceived` 를 `TRUE`로 변경

#### 2.2.4.5. Verify Can Message 

<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c

void verifyCanMessages(void)
{
    uint8 currentCanMessage;

    for(currentCanMessage = 0; currentCanMessage < NUMBER_OF_RECEIVED_MESSAGES; currentCanMessage++)
    {
        /* Check if the received message ID does NOT match with the transmitted message ID.
         * If this is the case, an error should be reported.
         */
        if(g_multican.rxMsg[currentCanMessage].id != CAN_MESSAGE_ID)
        {
            g_status = CanCommunicationStatus_Error_notExpectedMessageId;
            break;
        }

        /* Check if the received message length does NOT match with the expected message length.
         * If this is the case, an error should be reported.
         */
        if(g_multican.rxMsg[currentCanMessage].lengthCode != g_multican.canMsgObjConfig.control.messageLen)
        {
            g_status = CanCommunicationStatus_Error_notExpectedLengthCode;
            break;
        }

        /* Finally, check if the received data does NOT match with the transmitted one
         * If this is the case, an error should be reported.
         */
        if((g_multican.rxMsg[currentCanMessage].data[0] != (g_canInitialMessageData[0] | currentCanMessage)) ||
            (g_multican.rxMsg[currentCanMessage].data[1] != (g_canInitialMessageData[1] | currentCanMessage)))
        {
            g_status = CanCommunicationStatus_Error_notExpectedData;
            break;
        }
    }

    for(/*...*/; currentCanMessage < NUMBER_OF_CAN_MESSAGES; currentCanMessage++)
    {
        /* Check if the received message ID does NOT match invalid ID value.
         * If this is the case, an error should be reported.
         */
        if(g_multican.rxMsg[currentCanMessage].id != INVALID_ID_VALUE)
        {
            g_status = CanCommunicationStatus_Error_notExpectedMessageId;
            break;
        }

        /* Check if the received message length does NOT match invalid length value.
         * If this is the case, an error should be reported.
         */
        if(g_multican.rxMsg[currentCanMessage].lengthCode != INVALID_LENGTH_VALUE)
        {
            g_status = CanCommunicationStatus_Error_notExpectedLengthCode;
            break;
        }

        /* Finally, check if a received data does NOT match invalid data value.
         * If this is the case, an error should be reported.
         */
        if((g_multican.rxMsg[currentCanMessage].data[0] != INVALID_DATA_VALUE) ||
            (g_multican.rxMsg[currentCanMessage].data[1] != INVALID_DATA_VALUE))
        {
            g_status = CanCommunicationStatus_Error_notExpectedData;
            break;
        }
    }

    /* If there was no error, turn on the LED1 to indicate correctness of the received messages */
    if(g_status == CanCommunicationStatus_Success)
    {
        IfxPort_setPinLow(g_led1.port, g_led1.pinIndex);
    }
}


```
</div>
</details>

- 모든 메세지를 받은 이후에 실행되는 함수 
  - 메세지 ID 확인
  - 메세지 길이 확인
  - 데이터 확인
- for 반복문이 두번 있음
  - 첫번째 반복문에선 실제 수신한 데이터와 예상한 데이터를 비교함
  - 두번째 반복문에선 초기화 값이 변경되지 않았는지 확인함
- 모두 확인하고 에러가 없는 경우 LED 점등

#### 2.2.4.6. 궁금한점
1. 코어별로 모듈을 설정하지 않아도 되는건지?

### 2.2.5. Summary of MULTICAN

#### 2.2.5.1. 예제 요약 정리
2.2.1 부터 2.2.5까지의 내용 요약(배울수 있는 것)

1. 메세지 송수신
   - CAN Node 설정
   - CAN 프로토콜 설정(CAN, CANFD)
   - Message Object 설정
   - TX FIFO(Gateway), RX FIFO 설정
2. 인터럽트 설정


#### 2.2.5.2. 레지스터 

1. Multican 을 사용할때 쓰는 레지스터
   - 공통적으로 어떤 레지스터를 써서 모드를 바꾸는지

2. iLLD 매뉴얼, 유저 매뉴얼 보는 법

#### 2.2.5.3. 추가 질문

1. 내부 통신(루프백 모드)이 아닌 외부로 통신하기 위한 방법?
2. 인터럽트를 사용하지않고 CAN 송수신 가능한지? (Polling)
3. 외부 통신일때 디버깅 하는 방법? 오실로스코프, 로직분석기
4. CAN 통신 장치를 만드는 방법? RPi with CAN HAT(or CAN Shield)


## 2.3. Implementation of Communication with User Manual

뭘 만들어볼까

## 2.4. CAN Communication Using TC3xx Application Kit

### 2.4.1. 준비사항 
1. Windows 10 컴퓨터(노트북)
2. AURIX Development Studio - [how-to-setup](2024-03-14-HowToSetUpAURIXDevelopmentStudio.html)
3. TC3xx Application Kit
    - TC334 Lite Kit
    - TC375 Lite Kit
    - TC397 TFT

### 2.4.2. Analysis of TC3xx examples 

Example
1. MCMCAN_1_KIT_TC3xx
2. MCMCAN_FD_1_KIT_TC3xx
3. MCMCAN_Filtering_1_KIT_TC3xx

## 2.5. Additional Information

### 2.5.1. What is iLLD?

iLLD - Infineon Low Level Driver [Link](https://www.infineon.com/dgdl/Infineon-AURIX_Infineon_Low_Level_Driver-Training-v01_00-EN.pdf?fileId=5546d46269bda8df0169ca77502b254c)

<table>
  <tr>
    <td colspan="2"> Application Layer </td>
    <td rowspan="4"> Software </td>
  </tr>
  <tr>
    <td rowspan="3"> <strong>iLLD</strong> </td>
    <td>
    Function Level <br>
    - 주변 장치에 대한 동작을 사용할수 있게 만든 계층(초기화, 설정, 기능) <br>
    - ex) <br>
      <code>MODULE_STATUS Module_Init() { /* 초기화 코드 */}</code> <br>
      <code>MODULE_STATUS Module_SendMessege() { /* 메세지 전송 코드 */}</code>
    </td>
  </tr>
  <tr>
    <td> 
    Driver Level <br>
    - 함수 호출로 레지스터 설정을 쉽게 하기 위해 만든 계층 <br>
    - ex) <br>
      <code>MODULE_STATUS Module_TimerInit() { /* 타이머 기능 레지스터 설정 */ }</code> <br>
      <code>MODULE_STATUS Module_Send() { /* 전송 기능 레지스터 설정 */ }</code>
    </td>
  </tr>
  <tr>
    <td> 
    Special Function Register Level <br>
    - 레지스터 이름으로 접근할수 있는 계층 <br>
    - ex) <br>
      <code>#define REG_NAME PERIPHERAL_ADDR</code> <br>
      <code>#define REG_NAME_EN (1 << ADDR_POS)</code>
    </td>
  </tr>
  <tr>
    <td colspan="2"> Micom </td>
    <td> Hardware </td>
  </tr>
</table>

- Function Level 과 Driver Level이 비슷해 보일순 있지만 추상화의 단계가 다름.
  - Function Level은 기능 단위, Driver Level은 실제 레지스터 설정 단위이다.
  - 예를 들면 수신된 데이터를 읽는 함수가 function level, driver level 모두 있다고 하자
    - function level 에선 데이터를 읽고 가져온 데이터를 어디로 복사해둘지 초점을 맞춘다. 
    - driver level 에선 어느 주소에 접근해야 하는지 레지스터를 어떻게 바꿔야 하는지 등에 초점을 맞춘다.

(+) Differences between iLLD and MCAL(MC-ISAR)
- MCAL(Microcontroller Abstraction Layer)은 AUTOSAR 기반으로 만들어진 Low Level Driver임.
  - AUTOSAR를 준수한다는 것이 뭔지? FuSa? Security? AUTOSAR OS?
- iLLD와 MCAL은 코드 구조도 다름
- [Link](https://community.infineon.com/t5/AURIX/What-are-the-differences-between-an-Infineon-MC-ISAR-product-and-iLLD/td-p/316151)

### 2.5.2. Differences between MULTICAN and MCMCAN(MCAN)

1. About MULTICAN
   - Block Diagram
   - Message object?

2. About MCMCAN
   - Block Diagram
   - MCAN?

3. Differences

### 2.5.3. iLLD Sequence 궁금한 것. 설명

1. `Cpu0_main`은 어떻게 실행되는지? (어디서부터 시작해서 Cpu0_main에 닿는지)
   - 링크 스크립트(`.lsl`파일) 안에 `start_address`가 `_START` 심볼을 가리키고 있음
   - `_START`는 `IfxCpu_CStart0.c` 안에 있고 `_Core0_start`를 부름. 같은 파일 내에 해당 함수가 있고 초기 설정 등을 한 이후에 `core0_main`이 불림.
2. 멀티코어를 어떻게 돌릴 수 있는지?
   - `_Core0_start` 함수 내에서 `IfxCpu_StartCore` 를 통해서 특정 코어를 깨울 수 있음 
   - 코어 활성화, 비활성화는 define 해서 사용함.
3. CPU 인터럽트 활성화는 왜하는지?
   - `__enable()`: Enable interrupts by setting the Interrupt Enable bit (ICR.IE) in the Interrupt Control Register (ICR) to one (in TC2xx Core architecture vol.2)
   - Interrupt Service Routine을 사용하기 위해서 활성화 해야함.
4. Watchdog이 뭔지? 왜 disable 하는지?
5. 처음에 코어간 동기화를 하는데 왜 하는지?
   - 멀티코어를 쓰기위해서 동기화를 하는거 같긴한데 왜 하는지 잘 모르겠음.
6. 무한루프로 안꺼지게 하는데 벗어나면 어떻게 되는지?
   - 벗어난 경우 return 1로 끝나는데 에러가 뜨게 됨. 이 에러는 어디서 처리하는지?


### 2.5.4. 참고자료

illd tc27d user manual
- https://www.infineon.com/cms/en/product/gated-document/illd-um-tc27d-5546d4626df6ee62016df7e1ae1b018b/

https://www.infineon.com/cms/en/product/gated-document/tc37a-illd-um-1-0-1-11-0-5546d46272e49d2a0172ec2388417500/

illd tc37a user manual

- https://www.infineon.com/dgdl/Infineon-iLLD_UM_TC37A_1_0_1_11_0-Software-v01_00-EN.chm?fileId=5546d46272e49d2a0172ec2388417500&da=t

