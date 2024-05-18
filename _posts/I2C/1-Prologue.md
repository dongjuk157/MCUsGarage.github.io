# 1. Prologue

Concept of I2C

# 1.1 Introduce I2C

> I2C 는 Philips Semicondoctors 에서 1982년에 개발된 통신 방식이다.

## 특징

![회로도 구성](https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/I2C_controller-target.svg/1920px-I2C_controller-target.svg.png)

<b> I2C 회로도 구성 (출처 - 위키피디아) </b>

I2C는 동기식, multi-contoller/multi-target(즉 multi master/slave)방식의 시리얼 통신 버스이다.
데이터 통신은 SDA(데이터 신호)와 SCL(클럭 신호) 두 라인을 사용하며, 총 7비트의 통신 주소 공간을 가지며, 이론상 112개의 노드를 동시 연결 할 수 있다.

<table>
  <tr>
    <th> Wires Used </th>
    <td> 2 </td>
  </tr>
  <tr>
    <th> Maximum speed </th>
    <td>  </td>
  </tr>
  <tr>
    <th> Standdard mode </th>
    <td> 100kbps </td>
  </tr>
  <tr>
    <th> Fast mode </th>
    <td> 400kbps </td>
  </tr>
  <tr>
    <th> High speed mode </th>
    <td> 3.4Mbps </td>
  </tr>
  <tr>
    <th> Ultra fast mode </th>
    <td> 5Mbps </td>
  </tr>
  <tr>
    <th> Max # of Masters </th>
    <td> Unlimited </td>
  </tr>
  <tr>
    <th> Max # of Slaves </th>
    <td> 1008 </td>
  </tr>
</table>

## 장/단점

I2C 통신 프로토콜은 아래와 같은 장/단점을 가진다.

### 장점

- SDA와 SCL 두 가닥의 선만으로 데이터 송수신이 가능함.
- 동기식 통신이므로 비 동기식 통신인 UART 등에 비해 안정적임.
- BUS 형태로 다수의 I2C Master과 다수의 I2C Slave 장치를 연결할 수 있음. (단 통신 클럭은 1개의 마스터 장치만 제공 가능함.)

### 단점

- 속도가 느림 (표준 모드 기준 100kbps) UART 대비 빠르지만 SPI 대비 느리기 때문에 애매한 선택지인 경우가 많음. 그러나 최근 Fast I2C의 경우 최대 5Mbps까지 지원하는 경우도 있음.
- 반이중 통신이기 때문에 한 노드에서 데이터를 보내는 중에는 나머지 노드에서 데이터를 보낼 수 없음.
- 제어 레지스터, 주소, 전송 플래그 등 다양한 부분을 고려해야 하기 때문에 사용하기 복잡할 수 있음.
- 선만 연결해주면 되는 다른 쉬운 통신 방식(CAN 등)에 비해 데이터 통신을 위해 별도의 회로를 구성해야 함. (풀업 저항 구성이 필요함)

상기와 같은 특성으로 인해 I2C는 아래와 같은 응용에서 주로 사용된다.

- 센서류
- OLED, LCD 제어
- DAC 및 ADC 장치 연결
- EEPROM 연결 


## 동작 구조

### Physical Layer

![회로구성](https://upload.wikimedia.org/wikipedia/commons/2/27/Iicrp.png)  
I2C Physical Layer (출처 - 위키피디아)

- 피지컬 레이어에서, SCL과 SDA 라인은 오픈 드레인(MOSFET) 혹은 오픈 컬렉터(BJT) 버스 설계로 각 라인마다 풀-업 저항이 필요함.
- Low는 Ground, High은 Floating하게(풀업 저항으로 인하여 High로) 하여 제엏 할 수 있음. (즉 직접적인 High 출력을 수행하지 않음) 이를 통해 낮은 전류로도 신호를 제어할 수 있음.
- 그러나 고속 통신을 할 경우, 빠른 rising edge를 생성하기 위해 풀-업 저항 대신 직접 전류를 인가하여 SCL 혹은 SCL과 SDA를 제어할 수 있음.
- 이렇게 Default high로 제어할 경우 여러 노드가 동시에 라인을 제어할 수 있다는 장점이 있음.
  
![start comm, stop comm](https://www.analog.com/en/_/media/analog/en/landing-pages/technical-articles/i2c-primer-what-is-i2c-part-1-/36685.png?la=en&rev=bebf30881dea46a19f86abcbd41d2e0a)  
start stop comm (출처 - Analog Device)

- 편의를 위해 해당 단락에서는 데이터 송신자를 Master, 수신자를 Slave라고 정의함.
- No communication 상태일 경우 SCL과 SDA는 모두 High로 유지됨.
- 통신을 시작하기 위해서는 SDA를 Low로 바꾸면서 SCL은 High로 유지한 후 SCL을 Low로 천이 해야함.(SCL이 High인 동안 다시 SDA가 High로 가는 경우는 없음.)
- 동일하게 통신을 정지시키기 위해서는 SCL은 High로 유지한 후 SDA를 High로 천이해야 함.(SCL이 High인 동안 다시 SDA가 Low로 가는 경우는 없음.)
- 데이터 전송 중에는 SDA는 SCL이 Low일때만 천이되어야 함, SCL이 low인 동안 마스터의 SDA 출력은 해당 시점의 비트 데이터를 High나 Low로 결정함.
- 이후 마스터 컨트롤러는 SCL이 High가 되는 시점을 기다림, SCL 신호의 유효한 상승 시점은 Capacitor 혹은 Slave 장치의 clock stretching 여부에 따라 달라질 수 있음.
- SCL이 High가 된후 마스터 컨트롤러는 Slave가 비트 신호를 확인한 것을 확인하기 위해 일정 시간 (약 4us 수준)을 기다린 후 다시 Low로 천이함. 만약 clock stretching이 이뤄진다면 High로 천이하지 않았기 때문에 이 단계가 이뤄질 수 없음.

![clock stretching](https://onlinedocs.microchip.com/pr/GUID-CA6B1F8F-E09D-4780-A52A-CBBF61902464-en-US-2/GUID-E647A538-7685-4947-AC61-95FFF11E9521-low.png)  
clock stretching (출처 - Microchip)

- 만약 데이터를 수신하는 측이 처리 속도 느리거나 다른 이유로 데이터 수신을 멈추게 해야 할 경우 Clock Stretching이라는 기법을 통해 SDA 데이터 송신을 멈추게 할 수 있음.
- Clock Stretching은 SCL을 Low로 유지하여 데이터를 송신하는 Master측에서 데이터를 보내는것을 일시적으로 중단하게 할 수 있음.

- 8비트의 데이터를 송신한 후, 마스터는 슬레이브의 ACK 비트를 기다림, (마스터와 슬레이브의 데이터 방향이 바뀜) 이때 송신이 정상적으로 완료되면 slave는 0(ACK)을, 데이터 수신이 정상적으로 이뤄지지 않았다면 1(NACK)을 보냄. NACK는 다음과 같은 경우에 송신됨.
- Master가 Slave에게 보내는 경우
  - 데이터를 수신할 수 없거나, 해당 데이터 명령을 이해할 수 없거나, 더이상 데이터를 받을 수 없을 경우.
- Slave가 Master에게 데이터를 보내는 경우
  - 데이터 전송을 해당 바이트(8bit) 이후로 정지하고 싶을 경우.
- ACK NACK를 보내는 경우에만 SDA방향이 바뀌고 SCL은 여전히 Master가 제어함.
- ACK를 수신하면, 다시 Master은 세가지 동작 중 하나를 선택할 수 있음.
  - 정지 신호를 보냄, SDA를 Low로 한 후 SCL을 High로 천이한 후에 SDA를 High로 보냄.
  - 다른 데이터 바이트를 전송함, 마스터가 SDA를 set하고 controller가 SCL을 High 로 천이함.
  - Repeated start, SDA를 High로 천이하고, SCL을 High로 가게 한 후 SDA를 다시 Low로 보냄. 이렇게 할 경우 버스 릴리즈를 하지 않고 새 I2C 메세지를 전송할 수 있음.

![SDA Arbitartion](https://digilent.com/blog/wp-content/uploads/2015/02/I2C-arbitration.jpg)  
SDA Arbitartion (출처 - [digilent])

- 여러개의 I2C 디바이스가 하나의 버스에 연결되어 있을 경우 arbitration은 모든 컨트롤러가 버스의 정지 및 시작 비트를 모니터링하고 다른 컨트롤러가 버스를 사용 중일 때 메세지를 시작하지 않도록 하는 메커니즘임.
- 그러나 두 컨트롤러가 거의 동시에 전송을 시작할 수 있으며, 이 경우 arbitration이 발생함.
- 이 경우 각 컨트롤러는 SDA의 예상되는 현재 전압 레벨을 확인하여 예상값과 비교함. 이때 예상값과 다른 컨트롤러는 우선순위가 더 낮게 됨.
- 만약 두 컨트롤러가 서로 다른 컨트롤러에게 메세지를 보내는 경우, 더 낮은 타겟 주소를 보내는 컨트롤러가 address 데이터를 보내는 단계에서 더 높은 우선순위를 갖게 됨.
- SMbus나 PMbus의 경우 추가적인 arbitration 로직이 존재함.
- 이를 통해 I2C는 데이터 전송 중에 다수의 컨트롤러가 동시에 통신을 시도할 경우 arbitration 메커니즘을 사용하여 효과적으로 충돌을 방지하고 통신의 정확성을 보장할 수 있음.

### I2C 통신 속도 별 모드
- I2C 통신에는 여러 가지 운영 모드가 있으며, 이 모드들은 모두 100 kbit/s의 standard mode를 항상 사용할 수 있도록 호환됨.

- Standard mode : 100 kbit/s 속도로 동작합니다. 모든 I2C 장치가 이 모드를 지원함.
- Fast mode : 몇몇 타이밍 매개변수를 조정하여 400 kbit/s 속도를 달성. I2C 대상 장치에 널리 지원되며, 버스의 용량과 풀업 강도가 허용할 경우 사용할 수 있음.
- Fast mode plus : 더 강력한 (20 mA) 드라이버와 풀업을 사용하여 최대 1 Mbit/s를 달성. 표준 및 패스트 모드 장치(3 mA 풀다운 능력)와의 호환성을 유지하기 위해 풀업의 강도를 줄일 수 있어야 함.
- High speed mode : 3.4 Mbit/s 속도를 달성하며, 고속 전송 중에 활성 풀업이 있는 클록 라인을 컨트롤러가 가지고 있어야 함. 모든 고속 전송은 단일 바이트 "컨트롤러 코드"에 의해 선행되며, 이 코드는 고속 타이밍 모드로의 전환, 빠른 속도나 표준 속도 장치가 전송에 참여하지 않도록 보장해야 하며, 그리고 고속 전송 전에 arbitration이 완료됨을 보장해야 함.
- Ultra Fast mode : 쓰기 전용의 I2C 모드, 5 Mbit/s 전송 속도를 달성하기 위해 항상 데이터 라인을 active 상태로 둠. clock stretching, arbitration, read transfer 및 ACK가 모두 생략됨. 주로 LED 디스플레이에 사용됨.
- Non standard : 일부 제조업체가 최대 1.4 Mbit/s 속도로 제공하는 모드.

### 기본 통신 방식

![타이밍구성](https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/I2C_data_transfer.svg/600px-I2C_data_transfer.svg.png)  
I2C 통신 타이밍 (출처 - 위키피디아)

1. 우선 HW상 SDA와 SCL 모두 Rp(풀업 저항)을 이용해 Vdd(Vcc)에 연결하여 SDA SCL 회로를 High로 유지하도록 한다.(플로팅 방지)
2. SCL을 제공하는 마스터는 데이터를 전송할지 수신할지 결정한다. 이때 데이터를 송/수신할 때 반드시 슬레이브 주소를 마스터가 가지고 있어야 한다.
3. SDA와 SCL은 기본적으로 풀업저항에 의해 High 상태를 유지한다.
4. SCA가 low로 떨어지는 신호를 시작 신호 (S) 라고 판단 한다.
5. 이후 파란색 부분처럼 SCL이 Low로 떨어지는 시점이 SDA가 Bit 신호를 전환하는 시점이다.
6. 이후 SCL이 High가 되는 시점에 SDA의 High & Low 여부에 따라 데이터비트가 결정된다.
7. 모든 데이터를 수신한 후 SCL이 High로 유지된 후 SDA가 High로 변환되면 정지 신호로 판단하여 통신을 종료한다.

![Master Slave 간 통신 시퀀스](../assets/postsAssets/I2C/MS_comm.jpg)  
Master Slave 간 통신 시퀀스 (출처 - Digikey)

### Master to Slave (Write to Slave)

1. Master가 Slave에 데이터를 Write할 경우 시작 신호 S 이후 7비트의 Slave 주소를 Write 한다.
2. 이후 마지막 8번째 비트에 0을 Write한다.(마지막 bit가 0일 경우 Write 모드)
3. 이후 Slave가 데이터 수신을 할 준비가 완료되었다는 신호로 ACK 신호 (0)을 송신하면 Master은 8비트의 데이터를 송신하기 시작한다.
4. 매 8비트마다 Master로부터 데이터가 송신되면 Slave는 ACK 신호(0)를 보낸다.
5. 이후 데이터 전송이 전부 완료되면 마스터는 SCL을 High로 유지한 후 SDA를 High로 바꾼다.

### Slave to Master (Read from Slave)

1. Master가 Slave로부터 데이터를 Read 할 경우 시작 신호(S)이후 7비트의 Slave 주소를 Write 한다.
2. 이후 마지막 8번째 비트에 1을 Write 한다(마지막 bit가 1일 경우 Read 모드) 
3. 이후 Slave가 ACK 신호 (0)을 송신 후 데이터를 송신한다.
4. 매 8비트마다 Slave로부터 데이터가 송신되면 Master은 ACK 신호(0)를 보낸다.
5. 이후 데이터 전송이 전부 완료되면 마스터는 NACK(1)을 보낸 후 SCL를 Hgih로 유지 한 후 SDA를 High로 바꿈.