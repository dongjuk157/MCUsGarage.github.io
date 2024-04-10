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

### 2.2.2. MULTICAN in Flexible Data-Rate

### 2.2.3. MULTICAN using a Gateway with a TX FIFO

### 2.2.4. MULTICAN using RX FIFO

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
