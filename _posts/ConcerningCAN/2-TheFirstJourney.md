# 2. The First Journey
Communication with CAN

## 2.1. CAN Communication using TC275 Lite Kit

AURIX Development Studio 에 있는 CAN example 을 사용해서 실제 CAN 통신을 해 볼 것이다.

### 2.1.1. 준비사항 
1. Windows 10 컴퓨터(노트북)
2. AURIX Development Studio - [how-to-setup](2024-03-14-HowToSetUpAURIXDevelopmentStudio.html)
3. TC275 Lite Kit

## 2.2. Analysis of the examples

[AURIX Expert Training](https://www.infineon.com/cms/en/product/promopages/aurix-expert-training/)

Example
1. MULTICAN_1_KIT_TC275_LK-TR ([Link](https://www.infineon.com/dgdl/Infineon-AURIX_MULTICAN_1_KIT_TC275_LK-TR-Training-v01_00-EN.pdf?fileId=5546d4627a0b0c7b017a5868238f4cba))
2. MULTICAN_FD_1_KIT_TC275_LK-TR ([Link](https://www.infineon.com/dgdl/Infineon-AURIX_MULTICAN_FD_1_KIT_TC275_LK-TR-Training-v01_00-EN.pdf?fileId=5546d4627a0b0c7b017a586832ba4cbd))
3. MULTICAN_GW_TX_FIFO_1_KIT_TC275_LK-TR ([Link](https://www.infineon.com/dgdl/Infineon-AURIX_MULTICAN_GW_TX_FIFO_1_KIT_TC275_LK-TR-Training-v01_00-EN.pdf?fileId=5546d4627a0b0c7b017a586843c04cc0))
4. MULTICAN_RX_FIFO_1_KIT_TC275_LK-TR ([Link](https://www.infineon.com/dgdl/Infineon-AURIX_MULTICAN_RX_FIFO_1_KIT_TC275_LK-TR-Training-v01_00-EN.pdf?fileId=5546d4627a0b0c7b017a586853b24cc3))

### 2.2.1. MULTICAN

TC275 Lite Kit에 CAN Node를 두 개 만들고, 루프백 모드를 사용해서 서로 통신한다.
- Exchange Data Between Two CAN nodes, implemented in the same device using Loop-back mode.
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
  - initMultican: 멀티 캔 모듈 초기화
  - initLed: LED 모듈 초기화
  - transmitCanMessage: 캔 메세지 전송
- (꺼지지 않도록) 무한 루프


#### 2.2.1.2. Initialize MultiCAN Module

<details>
<summary><strong>Source Code</strong></summary>
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
     *  - define the GPIO port
     *  - define the GPIO pin that is the connected to the LED
     *  - define the general GPIO pin usage (no alternate function used)
     *  - define the pad driver strength
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

#### 2.2.1.5. Interrupt Service Routines for TX
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
void canIsrTxHandler(void)
{
    /* Just to indicate that the CAN message has been transmitted by turning on LED1 */
    IfxPort_setPinLow(g_led.led1.port, g_led.led1.pinIndex);
}
```
</div>
</details>

#### 2.2.1.6. Interrupt Service Routines for RX
<details>
<summary><strong>Source Code(Click)</strong></summary>
<div markdown="1">

```c
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

### 2.2.2. MULTICAN in Flexible Data-Rate

### 2.2.3. MULTICAN using a Gateway with a TX FIFO

### 2.2.4. MULTICAN using RX FIFO

### 2.2.5. Summary of MULTICAN

#### 2.2.5.1. 예제 요약 정리
2.2.1 부터 2.2.5까지의 내용 요약

1. 하나의 기기로 루프백 모드를 사용해서 통신하기(CAN)
2. CANFD
3. TX FIFO
4. RX FIFO

#### 2.2.5.2. 레지스터 

Multican 을 사용할때 쓰는 레지스터
- 공통적으로 어떤 레지스터를 써서 모드를 바꾸는지


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

iLLD - Infineon Low Level Driver

<table>
  <tr>
    <td colspan="2"> Application Layer </td>
    <td rowspan="4"> Software </td>
  </tr>
  <tr>
    <td rowspan="3"> <strong>iLLD</strong> </td>
    <td> Function Level </td>
  </tr>
  <tr>
    <td> Driver Level </td>
  </tr>
  <tr>
    <td> Special Function Register Level </td>
  </tr>
  <tr>
    <td colspan="2"> Micom </td>
    <td> Hardware </td>
  </tr>
</table>


(+) Differences between iLLD and MCAL
- [Link](not-yet)

### 2.5.2. Differences between MULTICAN and MCMCAN(MCAN)

1. About MULTICAN

2. About MCMCAN

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
