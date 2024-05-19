# What is Ethernet

이더넷이 뭘까? 이더넷은 일종의 네트워크 규약(프로토콜)이다. 하나의 인터넷 회선에 유선 혹은 무선 통신장비 그리고 다양한 허브 장치를 통해서 복수의 시스템이 연결되어 통신이 가능한 구조이다.

또한 LAN(Local Area Network), WAN(Wide Area Network)와 같은 네트워크 환경에서 거의 대다수를 차지하고 있는 프로토콜이라고 볼 수 있다. 실제 이 표준이 처음 상용화된 시기는 1980년이니 꽤 오랫동안 사용되어 왔다고 볼 수 있다. 이 오래된 프로토콜이 TCP/IP와 HTTP에 아주 밀접하게 결합되어서 현재도 아주 널리 사용되고 있는 중이다. 실제로 만약에 유선 인터넷이 연결된 환경에서 일하고 있다면 거의 대부분 이더넷을 사용 중이라고 볼 수 있다. 이 표준은 IEEE 802.3 통신 규격이다.

흔히 통신 쪽을 전공하지 않거나 혹은 컴퓨터에 관심이 없는 사람들이 하는 오해 중 대표적인 것은 인터넷 이더넷을 오해하는 것이다.

사실 이더넷은 과거에 빛의 매개물질로 생각했던 에테르(ether)라는 가상 물질에서 유래하였다. 그런데 사람들은 이 이더넷을 인터넷을 타이핑하다가 오타를 낸 것이 아니냐는 말을 가끔 하고는 한다.

사실 인터넷은 TCP/IP 기반 네트워크 환경이고, 이더넷은 네트워크 접근을 위한 컴퓨터 간의 일종의 규약 증, 프로트콜이라고 생각하면된다. 쉽게 생각하면 이더넷 외에도 인터넷을 동작하기 위한 프로토콜이 다수 존재한다는 점을 떠올리면 된다. OSI 계층에서 이더넷은 Layer 2 이하를 의미하고 인터넷은 L3 이상을 보통 의미한다.

우리가 가장 흔히 사용하는 네트워크 규격이기도 하다. 네트워크 계층으로 살펴보면 OSI 모델 7계층에서 Physical Layer와 Data Link Layer에 대해서 정의되어 있다.

이더넷은 네트워크를 만드는 방법 중 하나인데 CSMA/CD 프로토콜을 이용해서 통신을 한다. 이 방식 외에 다양한 방식이 있지만, 현재는 전세계에서 이더넷 방식이 가장 널리 사용되어지고 있다.

CSMA/CD는 Carrier Sense Multiple Access/Collision Detection의 약자이다.

{% include_relative EtherNet/1_1_CSMA_CD.md %}

{% include_relative EtherNet/1_2_HowTheEthernetProtocolWorks.md %}

<BR>

## Ethernet 발전 과정

- 1977 - 동축 케이블 기반 이더넷 개발(10Base-5)

- 1985 - IEEE 802.3 동축케이블 기반 이더넷 표준화(10Base-5,10Base-10)

- 1990 - IEEE 802.3i UTP 기반 이더넷 표준화(10Base-T)

- 1995 - IEEE 802.3u 100Mbps 고속 이더넷 표준화(100Base-TX/FX)

- 1998 - IEEE 802.3z 1Gbps 이더넷 표준화(1000Base-SX/LX/CX)

- 2002 - IEEE 802.3ae 10Gbps 이더넷 표준화(10GBase-S/L/E) 이때는 광케이블.

- 2006 - IEEE 802.3an 10Gbps UTP 이더넷 표준화(10GBase-T)

- 2010 - IEEE 802.3ba 100G 및 40G 이더넷 표준화. 여기서부터는 광케이블이 기본이다.

- 2016 - IEEE 802.3bz: 2.5G 및 5G 이더넷 표준화 - 1G 이더넷에서 널리 쓰이는 카테고리 5e 와 카테고리 6 케이블을 그대로 활용하여 속도를 올리고자 하는 목표로 만들어졌다. 10G로 바로 넘어가기에는 제약이 크기에 중간에 완충하는 효과를 기대할 수 있다. 대표적으로 메인 드라이브가 NVMe 규격이어야 한다는 제약. 이 기준에 미달되면 극심한 병목 현상이 나타난다. 최종 데이터가 HDD에 있다면 실제 순차 읽기 속도가 250MB/s 정도밖에 안되어서 2.5G 인터넷을 벗어나기 어렵다. 802.11ac, 802.11ax 160MHz 정도 되면 이미 1Gbps를 능가하고, LTE도 Category 에 따라서는 1Gbps 를 넘어서므로 [5] 상향 자체는 필요한 것이 현실적 이유.

- 2017 - IEEE 802.3bs 200GbE/400GbE 표준 제정.

- 2020 - 800GbE 표준 제정.

<BR>

## Reference

- [What is Ethernet](https://www.techtarget.com/searchnetworking/definition/Ethernet)

- [How the Ethernet Protocol Works - A Complete Guide](https://www.freecodecamp.org/news/the-complete-guide-to-the-ethernet-protocol/)

- [Ethernet Frame](https://www.youtube.com/watch?v=SoTRqDLND6Y)

<BR>
<BR>
<BR>
<BR>
