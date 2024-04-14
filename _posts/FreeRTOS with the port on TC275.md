---
title: FreeRTOS with the port on TC275 lite kit
author: Hoseok Lee
date: 2024-04-14
category: Jekyll
layout: post
---

# FreeRTOS with the port on TC275
In this project, our ultimate goal is to port FreeRTOS on Infineon Tricore TC275 Evaluation kit, understanding FreeRTOS. During this journey, we are going to handle topics such as FreeRTOS Theory, TC275 MCU Architecture, Hands-on Experiment, Development Enviornment, and Guidance for the experiment.

First, we will look at Free RTOS Theory elaborated in [Mastering-the-FreeRTOS-Real-Time-Kernel.v1.0]. This document written by Richard Barry and FreeRTOS team is very powerful to understand morden OS theory. Second, we will go over Infineon Tricore TC275 MCU Architecture, which is especially related to OS. Finally, we are going to move on hands-on experiment, the port on TC275 Evaulation kit based on these two prerequisites.

For the hands-on experirment, we will try to port FreeRTOS on TC275 Evaluation kit. This implementation will be based on [TC1775 Demo Project] and [Legacy FreeRTOS Port on TC277]. Especially, [Legacy FreeRTOS Port on TC277] is the contribution 9 years ago. If we found that several improvements are needed, we will do that. One of the goals of this project is to make it versatile, which means that we are not limited to several specific tools that need payment. So, when we implement the port on TC275, we are going to choose open source and tools that can be used free of charge. 

## Reference
-[Mastering-the-FreeRTOS-Real-Time-Kernel.v1.0]
-[TC1775 Demo Project]
-[Legacy FreeRTOS Port on TC277]
-[TC275 lite kit]
-[FreeRTOS Port on TC399]

## Hands on Experiment Development Environment
1. TC275 lite kit
2. Compiler: GCC
3. Development Environment: Windows or WSL
4. Reference Source Code: [TC1775 Demo Project] and [Legacy FreeRTOS Port on TC277]


[TC275 lite kit]:https://www.infineon.com/cms/en/product/promopages/AURIX-microcontroller-boards/low-cost-arduino-kits/AURIX-TC275-lite-kit/
[Mastering-the-FreeRTOS-Real-Time-Kernel.v1.0]:https://www.freertos.org/Documentation/RTOS_book.html
[TC1775 Demo Project]:https://www.freertos.org/FreeRTOS-for-Infineon-TriCore-TC1782-using-HighTec-GCC.html
[Legacy FreeRTOS Port on TC277]:https://interactive.freertos.org/hc/en-us/community/posts/210026366-FreeRTOS-7-1-Port-for-Aurix-TC27x-using-Free-Entry-Toolchain?_ga=2.60494381.1877225190.1712758092-1651550433.1712758092
[FreeRTOS Port on TC399]: https://forums.freertos.org/t/freertos-for-infineon-tc399xx/8399