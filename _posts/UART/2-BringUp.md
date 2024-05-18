# 2. Bring-up
# 2.1 Hardware Scheme
# 2.2 Simple Example of UART
### 예제 코드
- UART는 단순한 HW 구성, 프레임 구성 만큼이나 소스코드의 구현도 간단함.
- Infineon TC275 마이크로컨트롤러를 사용하여 UART 통신을 설정하는 과정은 다음과 같음:

1. **보드레이트 설정**: 원하는 보드레이트에 맞게 UART 모듈의 클럭을 설정함.
2. **데이터 형식 설정**: 데이터 비트, 패리티 비트, 정지 비트를 설정함.
3. **송신/수신 활성화**: UART 모듈의 송신(TX)과 수신(RX) 기능을 활성화함.


```c
#include <stdio.h>
#include <IfxAsclin_Asc.h>
#include <IfxPort.h>

// UART 모듈 초기화
void init_UART(void) {
    // UART 모듈 설정
    IfxAsclin_Asc_Config ascConfig;
    IfxAsclin_Asc_initModuleConfig(&ascConfig, &MODULE_ASCLIN0);

    // 보드레이트 설정 (9600bps)
    ascConfig.baudrate.prescaler = 1;
    ascConfig.baudrate.baudrate = 9600;
    ascConfig.baudrate.oversampling = IfxAsclin_OversamplingFactor_16;

    // 데이터 형식 설정 (8비트 데이터, 1비트 정지)
    ascConfig.frame.dataLength = IfxAsclin_DataLength_8;
    ascConfig.frame.stopBit = IfxAsclin_StopBit_1;

    // 모듈 초기화
    IfxAsclin_Asc_initModule(&asc, &ascConfig);
}

// 데이터 송신 함수
void send_UART(char *data) {
    while (*data) {
        // 데이터 송신
        IfxAsclin_Asc_blockingWrite(&asc, *data++);
    }
}

int main(void) {
    // UART 초기화
    init_UART();

    // 데이터 송신
    char message[] = "Hello, UART!";
    send_UART(message);

    while(1) {}
    return 0;
}