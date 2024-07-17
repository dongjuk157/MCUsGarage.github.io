# 1. Prologue

자동차 내부 통신을 위해 가장 많이 사용되는 CAN 프로토콜에 대해서 배울 것이다.

우선 CAN 프로토콜이 만들어지기 전의 상황을 간단하게 살펴보자.

초기의 자동차는 엔진의 구동부터 바퀴의 회전까지 모든 과정이 기계적인 움직임에 의존했다. 그러나 자동차의 성능(출력, 연비 향상) 등의 이유로 제어를 전자적으로 하게 되면서 ECU(전자 제어 장치, Electronic Control Unit)가 도입되었다. 이때까지는 각 부품 별로만 통신이 필요했고 센서와 ECU 간에 Point-to-point([wiki](https://en.wikipedia.org/wiki/Point-to-point_(telecommunications))) 이나 mesh([wiki](https://en.wikipedia.org/wiki/Mesh_networking)) network 방식으로 통신했다.

자동차가 발전하면서 안전성이나 편의성 등의 요구가 증가했고 전자 제어가 필요한 부품들이 더욱 많아졌다. 이에 따라 통신해야할 데이터의 양도 늘어났고, ECU 끼리의 통신도 빈번해졌다. 기존의 Point-to-point 방식으로 통신을 하려면 모든 ECU 사이에 통신선을 놓아야했기 때문에 ECU가 늘어날수록 차량의 무게가 점점 더 무거워지는 문제가 발생했다. 따라서 무게를 크게 증가시키지 않으면서 여러 ECU 사이의 통신을 원활하게 할수 있는 통신 방식이 필요했다.

이러한 요구에 BOSCH는 새로운 통신 방식을 개발했고 그 통신방식이 Controller Area Network(CAN)이다.

## 1.1. Concerning Communication

CAN에 들어가기 앞서 통신에 대해서 이해해보고 CAN과 관련된 기초 지식에 대해서 알아보자.

### What is Communication

우선 통신은 뭘까? 통신을 한다는 것은 개체간에 정보를 전달하는 과정이다. 통신은 다양한 형태로 이루어질수 있다. 예를 들면 사람들끼리 대화하는 것이나 인터넷 쇼핑을 하기 위해 특정 웹사이트에 접속하는 것이 있다. 

통신을 하기 위해선 여러가지 요소들이 필요한데 이를 몇가지 정리해보면 다음과 같이 나타낼수 있다.
1. 메세지(message): 전달하려는 정보. ex: 쇼핑물 상품 
2. 송신자(sender): 데이터를 보내는 주체. ex. 쇼핑몰 서버 
3. 수신자(receiver): 데이터를 받는 주체. ex. 유저 
4. 전송 매체(Medium): 데이터를 전달하는 물리적 경로. ex. 전선 
5. 프로토콜(Protocol): 통신의 규칙과 절차 ex. TCP/IP

요소들 중에 다른 것들도 중요하지만 프로토콜이 특히 중요하다고 생각한다. 통신을 위한 주체들이 본인의 데이터만을 보내려고하면 충돌이 자주 일어나게 되어 통신이 불가능 해질 것이다. 

또 다른 예로 특정 주제에 대해서 사람들끼리 토론을 한다고 해보자. 토론의 참가자들은 본인의 의견(message)을 주장할때 화자(sender)가 되고 반대 진영의 사람들은 청자(receiver)가 된다. 

이때 규칙(protocol)에 따라 토론의 양상이 달라질 것이다. 예를 들면 목소리가 큰사람이 발언권을 갖는 다는 규칙이 있으면 시간이 지날수록 모두 화자가 되어 버려 모든 사람이 소리를 질러 무슨 이야기를 하는지 모를 수준이 될 수 있다. 다른 규칙으로 중재자에게 발언권을 얻은 사람만 이야기 할수 있다고 한다면 뜻을 굽히진 않아도 이야기는 계속 이어지는 상황이 만들어 질 것이다.

이렇듯 규칙에 있어선 정답이 없다. 따라서 다양한 기기와 네트워크가 원활하게 협력할 수 있는 효과적인 프로토콜을 찾아야한다.

### Serial & Parallel Communication
통신 방식에 대해서도 몇가지 알아보자. 

![compare communications](../assets/postsAssets/ConcerningCAN/compare_serial_parallel.png)

위 그림은 데이터를 보내는 두 방식을 나타낸다. 병렬 통신(위), 직렬 통신(아래)

그림에서 볼 수 있듯 병렬 통신은 연결한 선 만큼 비트를 한번에 보낼 수 있고, 직렬 통신은 한 선에 비트를 순차적으로 보낸다.
- 직렬 통신에서의 순차적인 비트를 비트스트림(bitstream, [wiki](https://en.wikipedia.org/wiki/Bitstream))이라고 한다.

일반적으로 속도는 병렬 통신이 빠르다. 클럭의 한 주기에 비트 하나를 보낼수 있는 데이터 선이 있다고 해보자. 병렬 통신은 데이터 선을 연결한 만큼 한 주기에 배수로 보낼수 있다. 병렬 통신을 위해 8개의 데이터선이 있다고하면 한 주기당 8bit를 보낼수 있다. 직렬 통신에선 하나의 데이터 선만 사용하므로 한 주기당 1bit를 보낼수 있다. 이런 환경에서 32bit 데이터를 각각 보낸다고하면 8bit 병렬 통신은 4 주기에, 직렬통신은 32 주기에 통신을 끝낼 수 있다.

속도만 보면 좋아보이지만 병렬 통신에도 단점이 존재한다. 병렬 통신은 데이터 라인의 개수만큼 전선의 무게가 많이 늘어난다. 그리고 전선은 거리에 따라 노이즈가 많이 발생해서 길이를 길게 만들수도 없고 병렬로 놓인 전선끼리의 전자기 간섭으로 오류가 많이 발생한다.
- 또한 고속에서 사용하면 타이밍이 어긋나서 데이터를 잘못 읽는 문제도 있다고 한다.(timing skew, 출처: https://powerdeng.tistory.com/11)

<details>
<summary><strong>비교 정리 (Click)</strong></summary>

<div markdown="1">

<table border="1">
  <tr>
    <th>특성</th>
    <th>직렬 통신 (Serial Communication)</th>
    <th>병렬 통신 (Parallel Communication)</th>
  </tr>
  <tr>
    <td>전송 방식</td>
    <td>데이터를 한 번에 한 비트씩 순차적으로 전송</td>
    <td>여러 비트를 동시에 전송</td>
  </tr>
  <tr>
    <td>배선 구조</td>
    <td>간단 (송신선과 수신선만 필요)</td>
    <td>복잡 (여러 개의 데이터 라인 필요)</td>
  </tr>
  <tr>
    <td>전송 속도</td>
    <td>비교적 느림</td>
    <td>매우 빠름</td>
  </tr>
  <tr>
    <td>장거리 통신</td>
    <td>유리 (신호 손실이 적고 신뢰성 높음)</td>
    <td>부적합 (신호 손실과 간섭 문제)</td>
  </tr>
  <tr>
    <td>전자기 간섭</td>
    <td>적음 (전선 수가 적어 간섭이 적음)</td>
    <td>많음 (많은 전선으로 인해 간섭 발생 가능)</td>
  </tr>
  <tr>
    <td>비용</td>
    <td>저렴 (배선이 간단하고 설치 비용이 낮음)</td>
    <td>높음 (복잡한 배선 구조로 설치 비용 증가)</td>
  </tr>
  <tr>
    <td>신뢰성</td>
    <td>높음 (간단한 구조와 간섭 감소로 신뢰성 높음)</td>
    <td>낮음 (복잡한 구조와 간섭 문제)</td>
  </tr>
  <tr>
    <td>예시</td>
    <td>
    USB (Universal Serial Bus) <br>
    RS-232 (컴퓨터와 주변기기 간의 직렬 통신) <br>
    I2C (칩 간의 저속 직렬 통신) <br>
    SPI (칩 간의 고속 직렬 통신)
    </td>
    <td>
    병렬 프린터 포트 (컴퓨터와 프린터 간의 병렬 통신) <br>
    IDE (초기 컴퓨터의 하드 드라이브와의 병렬 통신) <br>
    PCI (컴퓨터 내부의 부품 간 병렬 통신)
    </td>
  </tr>
</table>
</div>
</details>

### Synchronous & Asynchrounous Communication

몇 가지 통신을 확인해보면 clock 이 들어가는 통신 방식(ex. SPI, i2C)이 있고 들어가지 않는 통신 방식(ex. UART)이 있다. 어떨땐 clock이 필요하고 어떨땐 clock이 필요없는 걸까?

우선 clock 이 왜 필요할까를 먼저 생각해보자. 송신자가 "12345678" 이란 데이터를 보낸다고 해보자. 이때 수신자는 받는 속도에 따라 데이터를 다르게 받아 들일것이다.
1. 수신자가 송신자와 같은 속도(1로 가정)로 받는 경우, 송신자가 보낸 데이터 그대로 받아올수 있다. "12345678"
2. 수신자가 송신자보다 빠른 속도(2로 가정)로 받는 경우, 이전 데이터가 중복되어 들어올 것이다. "1122334455667788"
3. 수신자가 송신자보다 느린 속도(0.5로 가정)로 받는 경우, 데이터가 씹혀서 들어올것이다. "1357" or "2468"

이 세가지 예를 보면 1)의 예시만 제대로 된 값을 받을수가 있고 2)는 데이터를 중복값을 제거하는 것과 같이 한 번 더 처리해서 사용해야하고 3)은 데이터가 유실되는 문제를 가지고 있다. 따라서 데이터 송수신 속도가 같아야지만 효율적으로 통신할 수 있고 이렇게 송수신 속도를 같게 하기위해 동기화라는 것이 필요하다.

동기화를 구현하기 위해서 두가지 방식이 존재한다. [wiki](https://en.wikipedia.org/wiki/Comparison_of_synchronous_and_asynchronous_signalling)
- 데이터 신호와 Clock 신호의 통신선을 분리하고 송신자가 보낸 클럭(혹은 외부 클럭)에 동기화를 맞추는 방식을 Synchronous 방식이라고 한다.
- 데이터 신호에서 clock을 뽑아내서 동기를 맞추는 방식을 Asynchrounous 방식이라고 한다. 
  - 데이터에서 클럭을 뽑아낸다는게 이상해 보일수 있을 것이다. 클럭 신호를 유추한다고 생각하면 된다. 유추하는 방법은 여러가지가 있겠지만 주로 메세지의 첫 시작을 HIGH와 LOW를 번갈아 보내는 걸로 유추할수 있다. 예를 들어 메세지의 첫 시작은 무조건 "010101"을 보낸다고 하자. 수신자가 사용하지 않는 상태에 있다가 데이터가 들어오는 것을 감지할수 있다. 이 때 받은 신호에서 0과 0 혹은 1과 1 사이의 주기를 측정하고 이를 통해 속도를 유추 할 수 있다.

### BUS Network (BUS Topology)

일반적인 버스 네트워크에 대해서도 알아보자.

<table>
  <tr>
    <th> General BUS </th>
    <th> Add a Node in BUS</th>
  </tr>
  <tr>
    <td> 
    <image src="../assets/postsAssets/ConcerningCAN/BUS_Network_General.png" alt="general_BUS"/>
    </td>
    <td> 
    <image src="../assets/postsAssets/ConcerningCAN/BUS_Network_General_2.png" alt="general_BUS_adding_a_node"/>
    </td>
  </tr>
</table>

우선 버스 네트워크의 특징은 확장에 유리하다. 
- 새로운 노드(데이터를 송수신할 수 있는 최소 장치, [wiki](https://en.wikipedia.org/wiki/Node_(networking)))를 추가할 때 기존 네트워크에 연결만 하면 된다. 

버스 네트워크는 Multi Master Network 이고 노드간 통신은 Half-duplex 방식이다. 
- Multi master Network라는 건 어떤 노드든 마스터가 되어 데이터를 보낼수 있다는 것이다. Sinlge Master Multi Slave 가 있을수 있고 이 경우는 한 노드만 마스터가 되고 나머지는 슬레이브가 되어 단방향으로만 데이터 송수신이 가능하다.
- Half-duplex(반이중통신)는 통신의 방향성을 나타낸다. 무전기처럼 양방향으로 통신이 가능하나 동시에 송수신은 불가능 하다. 이 외에도 Full duplex(전이중통신), Simplex(단방향 통신) 등이 있다. [wiki](https://en.wikipedia.org/wiki/Duplex_(telecommunications))
- 즉, BUS 네트워크는 일반적으로 여러 노드가 데이터를 송수신할 수 있고, 한 노드가 데이터를 송신하면 나머지 노드는 데이터를 수신하는 관계가 된다. 

여러 노드가 동시에 데이터를 전송해서 데이터를 사용하지 못하는 경우가 생기는데 이를 충돌(collision)이라 한다.
- 이를 해결하기 위해 우선 순위나 Media Access Control(MAC, [wiki](https://en.wikipedia.org/wiki/Medium_access_control))를 사용한다.

<details>
<summary><strong>point-to-point 방식과 비교(Click)</strong></summary>

<div markdown="1">

<table>
  <tr>
    <th> General BUS </th>
    <th> Add a Node in BUS</th>
  </tr>
  <tr>
    <td> 
    <image src="../assets/postsAssets/ConcerningCAN/P2P_1.png" alt="point-to-point"/>
    </td>
    <td> 
    <image src="../assets/postsAssets/ConcerningCAN/P2P_2.png" alt="point_to_point_adding_a_node"/>
    </td>
  </tr>
</table>

point-to-point 방식은 다른 노드와 통신하기 위해서 필요한 노드간에 통신선을 놓아야한다.
- 노드가 많을수록 새로운 노드를 위해 추가되는 통신선의 양이 많아진다.

통신 방식은 Half-Duplex 방식이지만 네트워크가 겹치지 않으므로 여러 노드에서 한 노드로 데이터를 보낼수 있다.

</div>
</details>


## 1.2. Concerning CAN

통신에 대해 간략하게 배웠으니 CAN 프로토콜에 대해서 배워보자. CAN은 자동차 산업 분야에 적용하기 위해 고안된 직렬 통신 프로토콜이다. 

### CAN BUS

CAN도 BUS 구조이다. 지난 챕터에 BUS 네트워크에 대해서 언급했으니 이해하기 쉽게 CAN BUS부터 확인하자.

<table>
  <tr>
    <th> General BUS </th>
    <th> CAN BUS </th>
  </tr>
  <tr>
    <td> 
    <image src="../assets/postsAssets/ConcerningCAN/BUS_Network_General.png" alt="general_BUS"/>
    </td>
    <td> 
    <image src="../assets/postsAssets/ConcerningCAN/BUS_Network_CAN.png" alt="CAN_BUS"/>
    </td>
  </tr>
</table>

CAN도 일반적인 BUS의 특성을 갖는다. 
- 이론적으론 무한한 노드를 연결할 수 있다. 실질적으론 버스 라인의 지연 시간과 전기 부하에 의해 갯수가 제한된다.
- 오래된 CAN Controller와 통신하는 CAN 노드 한정으로 서로 다른 identifier를 가진 노드는 최대 2032($2032 = 2^{11} - 2^4$)개만 연결할수 있다. 
  -  2.0A 기준 ID bit가 11개이므로 ID가 서로 다른 노드는 $2^{11}$개이다.
  -  1980년대 Intel CAN 컨트롤러(82526)는 최상위 7bit가 모두 1이면 안된다고 한다. 이 컨트롤러와 호환을 위해 $2^{11-7}= 2^4$ 개의 ID는 사용하지 못한다.

CAN은 연선 방식(Twisted Pair, [wiki](https://en.wikipedia.org/wiki/Twisted_pair))의 와이어를 사용하고 차동 신호 방식(Differential Signaling, [wiki](https://en.wikipedia.org/wiki/Differential_signalling))을 사용하여 데이터를 전송한다. 
- 연선 방식의 와이어는 잡음(noise)과 간섭(EMI)을 방지한다. 
- 두 개의 와이어는 각각 CAN-H와 CAN-L으로 사용하고 두 개의 와이어 사이의 전압 차이를 이용해 신호를 전달한다. 
  - Dominant(우성): CAN-H와 CAN-L이 전위차가 있는 경우를 뜻하며 논리적 레벨로 0이 된다. (실질적으론 이정도이다. CAN-H - CAN-L > 0.9V) 
  - Reccesive(열성): CAN-H와 CAN-L이 전위차가 없는 경우를 뜻하며 논리적 레벨로 1이 된다. (실질적으론 이정도이다. CAN-H - CAN-L < 0.5V)
  - Dominant, Reccesive각 논리 레벨로 0,1인 이유는 CAN BUS가 Wired AND Connection이기 때문에 (0이 존재하면 항상 0이 나오므로) 0이 항상 우세하다. 
    - [Meaning of Dominant & Reccesive](https://electronics.stackexchange.com/questions/112082/what-exactly-is-dominant-and-recessive)
    - [Wired_logic_connection](https://en.wikipedia.org/wiki/Wired_logic_connection)

충돌을 해결하기 위해 CSMA/CD(Carrier Sense Multiple Access / Collision Detection)와 AMP(Arbitration on Message Priority) 방식을 사용한다. 
- CSMA/CD는 충돌이 감지 되는 즉시 전송을 종료하고 충돌을 알린뒤 랜덤한 시간 뒤에 다시 신호를 보내는 방식이다. 
  - ![CSMA_CD_flow](../assets/postsAssets/ConcerningCAN/CSMA_CD_Flow.png)<br>(출처: csma/cd wikipedia)
  - [CSMA wiki](https://en.wikipedia.org/wiki/Carrier-sense_multiple_access)
  - [CSMA/CD wiki](https://en.wikipedia.org/wiki/Carrier-sense_multiple_access_with_collision_detection)
- AMP는 충돌이 발생한 경우 우선 순위가 높은 메세지(중요한 메세지)가 먼저 보내지고 충돌난 메세지는 이후에 다시 보내게 된다. 



### CAN Layer

CAN 통신의 기능들을 쉽게 이해하기 위해 CAN Layer에 대해서 살펴보자.

OSI 모델과 CAN Layer를 비교하면 명확하게 이해할 수 있겠지만 양이 너무 방대하니 CAN의 계층을 간단히 요약하자면 다음과 같다. 

1. Physical Layer (물리 계층)
   - PDU(전송단위): Bit, symbol
   - OSI 모델: 전기적 신호를 전송하고 물리적 연결을 설정하며, 데이터 전송 매체를 정의한다.
   - CAN: CAN의 물리 계층은 서로 다른 노드 간에 전기적 신호를 전달하는 역할을 한다. 외부 전기적 간섭에 강한 내성을 갖는다. 
   - Standard CAN:
     - Signal Level and Bit Representation
     - Transmission Medium
   - Extended CAN:
     - Bit Encoding/Decoding
     - Bit Timing
     - Synchronization
2. Data Link Layer (데이터 링크 계층)
   - PDU(전송단위): Frame([wiki](https://en.wikipedia.org/wiki/Frame_(networking)))
     - Frame 은 일반적으로 동기화 비트, 데이터(페이로드), 프레임 검사 시퀀스로 이루어져있고, interframe gap을 통해 다음 프레임과 구분된다.
   - OSI 모델: 데이터 프레이밍, 물리 주소 지정, 오류 검출 및 수정, 흐름 제어를 담당한다.
   - CAN: CAN 메시지 프레임은 이 계층에서 처리되며, 메시지의 우선순위를 결정하고 충돌을 방지하는 역할을 한다.
   - Standard CAN
     - Transfer Layer: 
       - Fault Confinement: 단기적인 오류(short distubances)와 영구적인 오류(permanent failures)를 구별한다. 영구적인 결함이면 사용못하게 한다.(switch off)
       - Error Detection: 모니터링(송신기측 비트레벨과 버스에서 감지된 비트레벨 비교), CRC, Bit Stuffing, Message Frame Check 등을 통해 오류를 감지한다.
       - Error Signaling: 메시지가 손상된 경우 전송이 중단 되고 재전송된다.
       - Message Validation: 메세지가 올바른지 확인한다.
       - Acknowledgment: 메세지를 수신했다고 알린다.
       - Arbitration: 버스에서의 충돌은 식별자를 사용해서 비트 단위로 중재한다. 동일 식별자를 가진 데이터프레임과 원격 프레임은 데이터 프레임이 우선된다.
       - Message Framing: 메세지 프레임 단위로 인식할수 있도록 묶고 푸는 작업을 한다.(Encapsulation/Decapsulation) 
       - Transfer Rate and Timing
     - Object Layer:
       - Message Filtering: 식별자를 읽고 데이터를 사용할지 선택한다.
       - Message and Status Handling: 메시지의 전송, 수신, 처리 상태를 관리해서 메세지 상태를 추적하고 오류를 감시한다. 
   - Extended CAN
     - Medium Access Control sublayer:
       - Data Encapsulation(Decapsulation): 메세지 프레임 단위로 인식할수 있도록 묶고 푸는 작업을 한다. (네트워크 레이어 <-> 데이터링크 레이어)
       - Frame Coding(Stuffing, Destuffing): 연속된 비트에 대해 반대 비트를 넣어주는 작업. 수신측에선 빼는 작업을 한다.
       - Medium Access Management: 네트워크 매체(버스)를 사용하는 여러 노드 간의 충돌을 방지하고, 효율적인 통신을 보장한다. (arbitration, CSMA/DA)
       - Error Detection: 모니터링(송신기측 비트레벨과 버스에서 감지된 비트레벨 비교), CRC, Bit Stuffing, Message Frame Check 등을 통해 오류를 감지한다.
       - Error Signaling: 메시지가 손상된 경우 전송이 중단 되고 재전송된다
       - Acknoledgment: 메세지를 수신했다고 알린다.
       - Serialization/Deserializaion: 송신 프레임을 보낼수 있는 비트단위로 쪼개고, 수신된 비트를 프레임으로 합치는 작업을 한다.(데이터링크 레이어 <-> 물리 레이어)
     - Logical Link Control sublayer: 
       - Acceptance Filtering: 식별자를 읽고 데이터를 사용할지 선택한다.
       - Overload Notification: 네트워크에서 프레임 전송이 지연되도록 신호를 보낸다. CAN 버스의 과부하를 방지하거나 다른 중요한 작업을 처리하기 위해 사용된다.
       - Recovery Management: 오류가 감지 되지 않은 경우 그 다음 메세지가 시작되도록 복구한다.
3. Network Layer 이상 (네트워크 계층 이상)
   - OSI 모델: 논리적 주소 지정, 경로 설정, 데이터 전송의 신뢰성을 보장, 통신 세션 관리, 데이터 형식 변환 및 최종 사용자와의 상호작용을 담당한다.
   - CAN: 네트워크 계층 이상의 기능은 다른 프로토콜(예: XCP, UDS on CAN 등)을 통해 구현될 수 있다.

용어가 어렵기도 하고, 계층에 대해서 설명하다가 갑자기 Standard CAN과 Extended CAN이 나와서 혼란스러울 수도 있다. 그래도 CAN의 기능들이 어떤게 있는지 어느정도 파악했으니 넘어가도록하자. 
- Standard CAN과 Extended CAN은 식별자(ID)비트의 수로 인한 차이를 제외하고선 용어만 다르게 정의되어있을뿐 크게 다르지 않다. 자세한 내용은 CAN Message 챕터에서 확인하자.
- 용어에 대한 설명들도 이후 챕터에서 자세히 설명하도록 하겠다.

<details>
<summary><strong>OSI 모델과 CAN의 비교(Click)</strong></summary>

<div markdown="1">

OSI 모델([wiki](https://en.wikipedia.org/wiki/OSI_model))은 한 번 정도는 읽어보고 이해할 필요가 있다. OSI 모델(Open Systems Interconnection Reference Model)은 표준 프로토콜을 사용하여 다양한 통신 시스템이 통신할 수 있도록 국제표준화기구에서 만든 개념 모델이다. OSI 모델은 통신 시스템을 7개의 계층으로 나누어 설명하는데, 이를 통해 각 계층의 역할과 기능을 명확히 할 수 있다.

특히 봐야할 것은 Layer 별 PDU이고 CAN은 Datalink Layer 아래에만 있다는 것이다.


<table>
  <tr>
    <th> OSI 7 Layers</th>
    <th> Protocol Data Unit (PDU) </th>
    <th> CAN 2.0 Part A<br>Standard CAN </th>
    <th> CAN 2.0 Part B<br>Extended CAN </th>
  </tr>
  <tr>
    <td> Application Layer </td>
    <td rowspan="3"> Data </td>
    <td>  </td>
    <td>  </td>
  </tr>
  <tr>
    <td> Presentation Layer </td>
    <td> </td>
    <td> </td>
  </tr>
  <tr>
    <td> Session Layer </td>
    <td> </td>
    <td> </td>
  </tr>
  <tr>
    <td> Transport Layer </td>
    <td> Segment </td>
    <td> </td>
    <td> </td>
  </tr>
  <tr>
    <td> Network Layer </td>
    <td> Packet </td>
    <td> </td>
    <td> </td>
  </tr>
  <tr>
    <td rowspan="2"> Data Link Layer</td>
    <td rowspan="2"> Frame </td>
    <td>
    <strong>Object Layer</strong><br>
    - Message Filtering<br> 
    - Message and Status Handling
    </td>
    <td> 
    <strong>Logical Link Control sublayer</strong><br>
    - Acceptance Filtering<br>
    - Overload Notification<br>
    - Recovery Management
    </td>
  </tr>
  <tr>
    <td> 
    <strong>Transfer Layer</strong><br>
    - Fault Confinement<br>
    - Error Detection and Signalling<br>
    - Message Validation <br>
    - Acknowledgment<br>
    - Arbitration<br>
    - Message Framing<br>
    - Transfer Rate and Timing
    </td>
    <td> 
    <strong>Medium Access Control sublayer</strong><br>
    - Data Encapsulation / Decapsulation<br>
    - Frame Coding (Stuffing / Destuffing)<br>
    - Medium Access Management<br>
    - Error Detection<br>
    - Error Signalling<br>
    - Acknowledgment<br>
    - Serialization / Deserialization
    </td>
  </tr>
  <tr>
    <td> Physical Layer </td>
    <td> Bit </td>
    <td>
    <strong>Physical Layer</strong><br>
    - Signal Level and Bit Representation<br>
    - Transmission Medium
    </td>
    <td>
    <strong>Physical Layer</strong><br>
    - Bit Encoding/Decoding<br>
    - Bit Timing<br>
    - Synchronization
    </td>
  </tr>
</table>

</div>
</details>




### CAN Message
이제 CAN 메시지의 구조에 대해 알아보자.

CAN 메시지는 CAN 네트워크에서 데이터를 주고받는 기본 단위이다. CAN 메시지는 총 7개의 다른 필드로 구성되어있다. 필드 내의 비트를 설정해서 메세지 포맷과 프레임 타입을 결정할수 있다.

메세지 포맷은 Standard CAN과 Extended CAN으로 나눌 수 있다.
- Standard CAN(CAN 2.0A)은 11 bit의 식별자 비트를 갖고 있어서 최대 2,048의 고유한 메세지 ID를 가질수 있다. CAN의 초기 스펙 (CAN 1.0)과 호환되도록 설계되었다.  
- Extended CAN(CAN 2.0B)은 29 bit의 식별자 비트를 갖고 있어서 최대 536,870,912개의 고유한 메세지 ID를 가질수 있다. Standard CAN과의 호환성을 위해 설계된 부분이 있다. 
  1. Extended ID: Standard 와 호환을 위해 11+18 bit로 쪼개어 사용한다. 앞 부분의 11bit ID가 같은 경우(Standard CAN 과 Extended CAN 이 충돌하는 경우) Extended CAN의 SSR 비트로 인해 Standard CAN이 항상 우선된다.
  2. Standard Control Field의 R1과 같은 위치에 Extended Arbitration Field의 IDE가 존재하고 서로 반대 비트를 가진다. R1: bit "0", IDE: bit "1"

<details>
<summary><strong>※ Controller 호환성 (Click)</strong></summary>

<div markdown="1">

Standard CAN(CAN 2.0A) Controller 는 standard CAN 포맷 방식의 메시지만 송수신이 가능하다.
- CAN 2.0 이전 사양(1.x)도 서로 통신할 수 있다
- Extended CAN 메시지를 수신하면 데이터를 무시한다

Extended CAN(CAN 2.0B) Controller 는 Standard, Extended 메시지 포맷 모두 송수신 가능하다.
- 만약 데이터 프레임이 standard와 extended 모두 같은 Base ID (첫 11 비트)를 가지면 Standard 데이터 프레임으로 인식한다. (SRR은 RTR 1로 인식)
- 요즘은 대부분 CAN2.0B 컨트롤러를 사용한다. 
</div>
</details>

메세지 프레임은 총 4가지가 있다.
1. Data Frame: 가장 기본적인 메세지 프레임이다. 데이터를 전달하기 위해 사용한다.
2. Remote Frame: 재전송을 요청할때 사용한다.
3. Error Frame: CAN 네트워크에서 오류를 감지했을 때 사용한다. CAN 노드는 데이터 전송 중 오류를 실시간으로 모니터링하며, 오류가 발생하면 즉시 에러 프레임을 전송하여 네트워크의 다른 노드에 알린다
4. Overload Frame: 프레임 사이에 추가 딜레이를 요청할때 사용한다. 주로 네트워크의 노드가 데이터 처리 속도를 따라잡지 못할 때 사용된다. 

각각의 메세지 프레임을 살펴보면서 필드와 비트가 어떤 의미인지 확인해보자  

#### Data Frame
데이터를 전달하기 위한 메세지 프레임이다.
![Data Frame](../assets/postsAssets/ConcerningCAN/DataFrame.png)

1. 시작 프레임(Start of Frame, SOF): 데이터 프레임의 시작을 나타낸다. 
   - 1비트의 'Dominant' 신호이다. (0b0)
2. Arbitration Field (중재 필드): 식별자를 포함하고 있으며 REMOTE 프레임과 구분하기 위한 비트가 있다. 식별자는 메시지의 우선순위를 결정하고 네트워크 내에서 메시지를 구별하는 데 사용된다.
   - Standard CAN: 11비트 식별자, RTR (IDE=0b0, r0 비트, Control Field)
   - Extended CAN: 11비트 기본 식별자, SRR, IDE=1, RTR, 18비트 확장 식별자
3. 제어 필드(Control Field): 데이터 길이 코드(DLC)를 포함하며, 전송되는 데이터의 길이를 나타낸다.
   - Standard CAN: IDE = 0b0, r0 비트, DLC (4비트)
   - Extended CAN: r1, r0 예약 비트 + DLC (4비트)
4. 데이터 필드(Data Field): 실제 전송되는 데이터가 포함되며, 최대 8바이트의 데이터를 담을 수 있다. 이는 CAN 메시지의 핵심 부분으로, 필요한 정보를 전송하는 역할을 한다.
5. CRC 필드(CRC Field): 오류 검출을 위한 사이클릭 중복 검사(CRC) 코드를 포함한다. 데이터 전송 중 발생할 수 있는 오류를 검출하여 데이터의 무결성을 보장한다.
6. ACK 필드(Acknowledgement Field): 메시지의 수신을 확인하는 비트이다. 수신 노드는 이 필드를 통해 메시지를 성공적으로 수신했음을 송신 노드에 알린다.
7. 종료 프레임(End of Frame, EOF): 프레임의 끝을 나타낸다.
   - 7비트의 'Recessive' 신호이다. (0b1111111)



<details>
<summary><strong>비교 정리 (Click)</strong></summary>

<div markdown="1">

![Differences Between Standard and Extended](../assets/postsAssets/ConcerningCAN/Difference_Standard_Extended.png)


<table>
    <tr>
        <th>Bitfield</th>
        <th>Standard CAN</th>
        <th>Extended CAN</th>
    </tr>
    <tr>
        <td>Start Of Frame<br>(SOF)</td>
        <td>
            1bit, bit "0"<br>
            메시지 프레임의 맨 앞에 위치함 
        </td>
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td rowspan="5">Arbitration Field</td>
        <td>ID (11-bit)</td>
        <td>Base ID (11-bit)</td>
    </tr>
    <tr>
        <td>
        RTR (1-bit), bit "0"<br>
        해당 메시지가 데이터 프레임이라는 것을 가리킴<br>
        - bit "1": 원격전송 요청(RTR : Remote Transmission Request)을 의미함.
        </td>
        <td>
        SSR (Substitute Remote Request, 1-bit)<br>bit "1"
        </td>
    </tr>
    <tr>
        <td></td>
        <td>IDE (1-bit), bit "1"</td>
    </tr>
    <tr>
        <td></td>
        <td>Extended ID (18-bit)</td>
    </tr>
    <tr>
        <td></td>
        <td>
        RTR (1-bit), bit "0"<br>
        해당 메시지가 데이터 프레임이라는 것을 가리킴
        </td>
    </tr>
    <tr>
        <td rowspan="3">Control Field</td>
        <td>Reserved 1, bit "0"(IDE)</td>
        <td>Reserved 1, bit "0"</td>
    </tr>
    <tr>
        <td>Reserved 0, bit "0"</td>
        <td>Reserved 0, bit "0"</td>
    </tr>
    <tr>
        <td>Data Length Code (4-bit)<br>0~8 byte 전송 가능</td> 
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td>Data Field</td>
        <td colspan="3">
        한 노드로부터 다른 노드로 전하고자 하는 데이터를 포함함.<br>
        DLC에 맞는 길이로 구성됨
        </td>
    </tr>
    <tr>
        <td rowspan="2">CRC Field</td>
        <td>CRC Sequence(15-bit)<br>
        CRC polynomial = 0b_1100_0101_1001_1001
        </td>    
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td>CRC Delimiter (1-bit), bit "1"</td>
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td rowspan="2">ACKnowledge Field</td>
        <td>
        ACK Slot (1-bit), bit "0"<br>
        다른 노드가 메시지를 성공적으로 수신하면 bit "1"로 변경함
        </td>
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td>ACK delimiter(1-bit), bit "1"</td>
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td>End Of Frame Field<br>(EOF)</td>
        <td>7-bit, 7bit 모두 "1"</td>
        <td>Standard CAN 과 동일</td>
    </tr>
</table>
 
</div>
</details>


<details>
<summary><strong>심화내용: Interframe Spacing(Click)</strong></summary>

<div markdown="1">

#### Interframe Spacing

메세지 프레임을 구분하기 위한 장치
- Data Frame 및 Remote Frame은 interframe spacing을 통해 이전 프레임과 구분된다.
- Overload Frame 및 Error Frame은 해당 비트필드로 구분되지 않는다.


<table>
    <tr>
        <th>Bitfield</th>
        <th>Standard CAN</th>
        <th>Extended CAN</th>
    </tr>
    <tr>
        <td>Intermission</td>
        <td colspan="2">
        3 'recessive' bit<br>
        INTERMISSION 중에는 어떤 스테이션도 DATA FRAME 또는 REMOTE FRAME의 전송을 시작할 수 없음<br>
        OVERLOAD 조건을 알리는 것 외엔 아무것도 할 수 없음
        </td>
    </tr>
    <tr>
        <td>Bus Idle</td>
        <td colspan="2">
        BUS IDLE period는 임의의 길이일 수 있음<br>
        전송할 내용이 있는 모든 스테이션에서 버스에 액세스할 수 있음<br>
        다른 메시지 전송 중에 전송 보류 중인 메시지는 INTERMISSION 다음의 첫 번째 비트에서 시작됨<br>
        버스에서 'Dominant' 비트 감지는 프레임 시작으로 해석됨
        </td>
    </tr>
    <tr>
        <td>Suspend Transmission</td>
        <td colspan="2">
        'error passive' 스테이션의 경우에만 포함됨<br>
        'error passive' 스테이션은 메시지를 전송한 후 추가 메시지 전송을 시작하거나 버스가 Idle상태임을 인식하기 전에 INTERMISSION 다음에 8개의 'recessive' 비트를 보냄<br>
        그 동안 다른 스테이션에 의해 전송이 시작되면 스테이션은 이 메시지의 수신자가 됨
        </td>
    </tr>
</table>

해당 프레임이 끝나면 CAN 버스라인은 IDLE 상태로 인식된다.

</div>
</details>


<details>
<summary><strong>심화내용: Remote Frame(Click)</strong></summary>

<div markdown="1">

#### Remote Frame

재전송을 요청하는 프레임이다. 
![RemoteFrame](../assets/postsAssets/ConcerningCAN/RemoteFrame.png)

전체적으로 Data Frame과 비슷하지만 RTR 비트가 1이어야하고 데이터 필드가 없다.

<table>
    <tr>
        <th>Bitfield</th>
        <th>Standard CAN</th>
        <th>Extended CAN</th>
    </tr>
    <tr>
        <td>Start Of Frame<br>(SOF)</td>
        <td>
            1bit, bit "0"<br>
            메시지 프레임의 맨 앞에 위치함 
        </td>
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td rowspan="5">Arbitration Field</td>
        <td>ID (11-bit)</td>
        <td>Base ID (11-bit)</td>
    </tr>
    <tr>
        <td>
        RTR (1-bit), bit "0"<br>
        해당 메시지가 데이터 프레임이라는 것을 가리킴<br>
        - bit "1": 원격전송 요청(RTR : Remote Transmission Request)을 의미함.
        </td>
        <td>
        SSR (Substitute Remote Request, 1-bit)<br>bit "1"
        </td>
    </tr>
    <tr>
        <td></td>
        <td>IDE (1-bit), bit "1"</td>
    </tr>
    <tr>
        <td></td>
        <td>Extended ID (18-bit)</td>
    </tr>
    <tr>
        <td></td>
        <td>
        RTR (1-bit), bit "0"<br>
        해당 메시지가 데이터 프레임이라는 것을 가리킴
        </td>
    </tr>
    <tr>
        <td rowspan="3">Control Field</td>
        <td>Reserved 1, bit "0"(IDE)</td>
        <td>Reserved 1, bit "0"</td>
    </tr>
    <tr>
        <td>Reserved 0, bit "0"</td>
        <td>Reserved 0, bit "0"</td>
    </tr>
    <tr>
        <td>Data Length Code (4-bit)<br>0~8 byte 전송 가능</td> 
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td rowspan="2">CRC Field</td>
        <td>CRC Sequence(15-bit)<br>
        CRC polynomial = 0b_1100_0101_1001_1001
        </td>    
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td>CRC Delimiter (1-bit), bit "1"</td>
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td rowspan="2">ACKnowledge Field</td>
        <td>
        ACK Slot (1-bit), bit "0"<br>
        다른 노드가 메시지를 성공적으로 수신하면 bit "1"로 변경함
        </td>
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td>ACK delimiter(1-bit), bit "1"</td>
        <td>Standard CAN 과 동일</td>
    </tr>
    <tr>
        <td>End Of Frame Field<br>(EOF)</td>
        <td>7-bit, 7bit 모두 "1"</td>
        <td>Standard CAN 과 동일</td>
    </tr>
</table>

</div>
</details>

<details>
<summary><strong>심화내용: Error Frame(Click)</strong></summary>

<div markdown="1">


#### Error Frame

에러 프레임은 CAN 네트워크에서 오류를 감지하고 처리하기 위해 사용된다. CAN 노드는 데이터 전송 중 오류를 실시간으로 모니터링하며, 오류가 발생하면 즉시 에러 프레임을 전송하여 네트워크의 다른 노드에 알린다. 에러 프레임이 전송되면, 네트워크의 모든 노드는 현재 전송 중인 메시지를 무시하고 버린다. 그런 다음, 문제가 있는 메시지는 자동으로 재전송된다.

![Error Frame](../assets/postsAssets/ConcerningCAN/ErrorFrame.png)

에러 프레임은 두 가지 부분으로 구성된다
1. 에러 플래그 (Error Flag)
   - 활성 에러 플래그 (Active Error Flag): 0b000000 
   - 이 플래그는 에러 액티브 상태(Active Error State)에 있는 노드에서 전송된다. 비트 스터핑 위반을 통해 오류 발생을 네트워크 상의 다른 노드에 알린다.
   - 수동 에러 플래그 (Passive Error Flag): 0b111111 
   - 이 플래그는 에러 패시브 상태(Passive Error State)에 있는 노드에서 전송된다. 에러 패시브 상태는 노드가 일정 수준 이상의 오류를 경험했음을 나타내며, 네트워크의 다른 노드들에게 덜 방해가 되도록 설계되었다. 네트워크 상의 다른 노드들이 6비트의 연속된 recessive 비트를 감지하면 수동 에러 플래그가 완성된 것으로 간주된다.
2. 에러 딜리미터 (Error Delimiter)
   -  0b11111111 (8 ’recessive’ bits)
   - 에러 플래그 뒤에 오고 에러 프레임의 끝을 나타낸다. 이는 네트워크가 에러 프레임의 종료를 인식하고 다음 데이터 전송을 준비할 수 있도록 한다.

<table>
    <tr>
        <td>Error Flag</td>
        <td colspan="2">
Active Error: <br>
Passive Error: <br>
에러를 감지한 'error active' 스테이션은 active error flag를 전송함. SOF부터 CRC까지 모든 필드에 적용되는 비트 스터핑을 위반해서 다른 스테이션에 알림.<br>
6개의 동일한 비트가 감지되면 PASSIVE ERROR FLAG가 완료됨.
        </td>
    </tr>
</table>



</div>
</details>

<details>
<summary><strong>심화내용: Overload Frame(Click)</strong></summary>

<div markdown="1">


#### Overload Frame

오버로드 프레임은 네트워크의 노드가 데이터 처리 속도를 따라잡지 못할 때 사용된다. 오버로드 프레임은 수신 측 노드가 과부하 상태임을 나타내어 송신 측이 데이터를 전송하기 전에 잠시 대기하도록 한다. 이는 네트워크의 안정성을 유지하고 데이터 손실을 방지하는 데 도움이 된다.

![Overload Frame](../assets/postsAssets/ConcerningCAN/OverloadFrame.png)

오버로드 프레임은 두 가지 부분으로 구성된다
1. 오버로드 플래그 (Overload Flag):
   - 0b000000
   - 이 플래그는 비트 스터핑 규칙을 위반하여 네트워크 상의 다른 노드들이 이를 감지할 수 있도록 한다.
   - 오버로드 플래그는 최대 두 개의 연속된 프레임으로 전송될 수 있다.
2. 오버로드 딜리미터 (Overload Delimiter):
   - 0b11111111
   - 오버로드 플래그 뒤에 오며 오버로드 프레임의 끝을 나타낸다. 


</div>
</details>



### CAN 메세지 송수신 과정

메세지 전송 과정에 대해서 알아보자

![Flow_Chart_CAN_Transmission](../assets/postsAssets/ConcerningCAN/Flow_Chart_CAN_Transmission.png)
출처: https://www.javatpoint.com/can-protocol

1. 메시지 송신 전에 CAN 버스 라인이 사용 중인지 파악한다.
   - 버스가 유휴(IDLE) 상태일 때만 메시지를 전송할 수 있다.
2. 사용 중이지 않으면 메세지를 보내고 사용 중이면 기다린다.
   - 여러 노드가 메세지를 송신할수 있다. 이 경우 메세지가 충돌날 수 있지만 우선순위가 높은 한 메세지만 남고 나머지 노드는 대기한다.
   - 데이터가 전송되는 동안 에러가 감지되면 에러 메세지를 전송하고 해당 메세지는 폐기한다.
3. 메세지를 수신한 모든 노드는 ID를 확인해서 필요한 메세지만 받고 나머지는 무시한다.
   - CAN 네트워크에서 각각의 노드를 식별할 수 있도록 각 노드 마다 유일한 식별자(11bit 또는 29bit)를 갖는다.
   - 메시지를 수신한 ECU는 데이터를 처리하고 필요한 경우 응답 메시지를 생성하여 다시 전송한다.


### Other things related to CAN 2.0A

#### Message Validation
메세지가 유효하다고 판단되는 시점
- 송신기: 보내는 메세지의 EOF가 끝날 때까지 오류가 없는 경우
- 수신기: 받는 메세지의 EOF가 마지막 1비트까지 오류가 없는 경우

#### Coding
Data Frame과 Remote Frame의 SOF 부터 CRC Sequence 까지만 bit stuffing이 사용된다.
- bit stuffing: 연속되는 5개의 동일한 비트가 감지되면 자동으로 반대 비트를 섞어서 보내는 것.

비트스트림은 NRZ([wiki](https://en.wikipedia.org/wiki/Non-return-to-zero)) 방식으로 코딩된다.
- NRZ(Non Return to Zero): 한 비트를 표현할 때 전압을 계속 유지한다.
- RZ(Return to Zero): 한 클럭 내에서 데이터의 전압을 표현하고 다시 0으로 돌아간다.

![Compare-NRZ-RZ](https://upload.wikimedia.org/wikipedia/commons/9/95/Digital_signal_encoding_formats-en.svg)

출처 - wikipedia

#### Error Handling

**Error Detection**

1. Bit Error: 보낸 비트값이랑 버스에서 모니터링된 값이 다른 때
2. Stuff Error: 비트 스터핑이 잘못 되었을 때
3. CRC Error: 계산된 CRC 값과 수신된 결과가 다를 때
4. Form Error: 고정된 형식의 비트필드에 잘못된 비트가 포함된 때
5. Acknowledgment Error: ACK SLOT에서 수신기가 값을 바꾸지 않은 때

(+) 오류들은 같이 뜰 수 있음

**Error Signalling**

오류를 감지한 노드는 Error Flag를 전송한다.
- Error Active Node: Active Error Flag 전송
- Error Passive Node: Passive Error Flag 전송

#### Fault Confinement

Fault Confinement 과 관련해서 송수신기는 아래 세 가지 상태 중에 있을 수 있다.

1. Error Active
   - 버스 통신에 참여할수 있음
   - 오류가 감지되면 Active Error Flag 전송함
2. Error Passive
   - 버스 통신에 참여할수 있음
   - 오류가 감지되면 Passive Error Flag 전송함
   - 플래그 전송후 추가 전송을 시작하기전 대기함
3. Bus Off
   - 버스에 어떤 영향도 미칠수 없음.

결함 제한을 위해 모든 버스 장치에 오류 횟수를 저장한다.
1. 전송 오류 횟수
2. 수신 오류 횟수

이러한 개수는 총 12개의 규칙에 따라 변경된다.
- 자세한 내용은 can 스펙 참조

### Other things related to CAN 2.0B

웬만한건 CAN 2.0 A와 겹치므로 Extended CAN에만 있는 내용을 추가했다.

#### Message Filtering

전체 식별자를 기반으로 필터링된다
- 마스크 레지스터를 사용하여 연결된 수신 버퍼에 매핑할 식별자 그룹을 선택할 수 있다.
- 마스크 레지스터의 모든 비트는 프로그래밍 가능해야 한다. (메시지 필터링을 위해 활성화하거나 비활성화할 수 있다.)


### CAN Protocol Variant  
High Speed CAN(ISO 11898)
- 1Mbps 이상의 고속 통신이 가능하다.
- Twisted Wire 끝에 120옴 저항이 달린다.
- 노이즈에 강하다.

Low Speed CAN(ISO 11519)
- 125Kbps 까지의 속도로 통신이 가능하다.
- Twisted Wire를 사용하나 한줄이 끊어져도 정상적으로 통신이 된다.
- ECU와 버스 사이에 120옴 저항이 달린다.

## 1.2. Concerning CAN FD

CAN with Flexible Data-Rate


자동차가 발전하면서 안전성이나 편의성 등의 요구가 증가했고 전자 제어가 필요한 부품들이 더욱 많아졌다. 이에 따라 통신해야할 데이터의 양도 늘어났고, ECU 끼리의 통신도 빈번해졌다. 기존의 Point-to-point 방식으로 통신을 하려면 모든 ECU 사이에 통신선을 놓아야했기 때문에 ECU가 늘어날수록 차량의 무게가 점점 더 무거워지는 문제가 발생했다. 따라서 무게를 크게 증가시키지 않으면서 여러 ECU 사이의 통신을 원활하게 할수 있는 통신 방식이 필요했다.

이러한 요구에 BOSCH는 새로운 통신 방식을 개발했고 그 통신방식이 Controller Area Network(CAN)이다.

<!--

### 특징

CAN 2.0 프로토콜과 호환된다.
- ISO 11898-1에 따라 모든 CAN 메세지를 송수신 할 수 있음
- Data Link Layer, Physical Layer는 CAN 2.0 B 와 동일함
CAN 보다 빠르고 더 많은 비트를 전송할 수 있다.
- Classic CAN: 1 MBit/s, 8 Byte/Frame
- CAN FD:
  - Bit rate: Control Field의 BRS로 속도를 조절함
    - 1 MBit/s(Arbitration phase)
    - 8 MBit/s(Data Phase) 
  - DLC: 0~8 Bytes(CAN 호환) + 8~64 Bytes(추가)

프레임 형식이 추가 되었다.
- 4가지 프레임 형식(CAN or CANFD / BASE or EXTENDED)
   1. CAN BASE FORMAT: 11 bit long identifier and constant bit rate
   ![CAN_Base_Format](../assets/postsAssets/ConcerningCAN/CAN_Base_Format.png)
   2. CAN EXTENDED FORMAT: 29 bit long identifier and constant bit rate
   ![CAN_Extended_Format](../assets/postsAssets/ConcerningCAN/CAN_Extended_Format.png)
   3. CAN FD BASE FORMAT: 11 bit long identifier and dual bit rate
   ![CANFD_Base_Format](../assets/postsAssets/ConcerningCAN/CANFD_Base_Format.png)
   4. CAN FD EXTENDED FORMAT: 29 bit long identifier and dual bit rate
   ![CANFD_Extended_Format](../assets/postsAssets/ConcerningCAN/CANFD_Extended_Format.png)

CAN FD에는 Remote Frame이 없다.

-->

## 1.3. Note on the car industry history 
CAN 이전 Mesh 형 토폴로지 사용
- GM사의 캐딜락

1986년 BOSCH, Automotive Serial Controller Area Network 개발
- 벤츠 요구
- 87년 Intel, CAN controller 출시
- 91년 MB CAN 적용 양산 차량(W140) 출시

1991년 CAN 2.0 발표
- part A 11 bit
- part B 29 bit

1993년 ISO CAN 표준 발표
- ISO 11898-1: Data link layer
- ISO 11898-2: 비내결함성 CAN physical layer(고속)
- ISO 11898-3: 내결함성을 위한 CAN physical layer(저속)
  - 11519-2
  - 95년 11898

1996년 OBD-II 표준 미국 의무화 
- 자동차, 경트럭 등

2001년 EOBD 표준 의무화(가솔린) 

2004년 EOBD 표준 의무화(디젤) 

2012년 Bosch CAN FD 1.0 발표 

2018년 CiA CAN XL 개발 시작

- 폭스바겐 요구
