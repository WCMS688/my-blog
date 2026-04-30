+++
title = "别再只会堆电容了：一份真正有用的 PCB 电源设计检查清单"
date = 2026-04-29T20:00:00+08:00
draft = false
slug = "pcb-power-design-checklist"
description = "高速高密电路的 PCB 电源设计问题与检查清单。"
tags = ["PCB", "Power Integrity", "PI", "PDN", "电源设计"]
categories = ["硬件设计"]
columns = ["高速电路专栏"]

+++
# 高速高密电路的 PCB 电源设计问题与检查清单

> 研究时间：2026-05-01  
> 研究对象：高速高密 PCB 的电源分配网络（PDN/PDS）、电源完整性（PI）、去耦、层叠、BGA/HDI 供电、验证与调试  
> 方法：横纵分析法  

## 一句话判断

高速高密 PCB 的电源设计，已经从「把每路电压接过去」变成了「在芯片封装焊球处维持低阻抗、低噪声、低压降、可验证的动态供电系统」。真正的风险不在某一个 0.1 uF 电容少没少，而在整条链路：VRM、bulk 电容、板级去耦、平面电容、BGA/via、封装、片上电容、负载瞬态和测量方法有没有闭合。

如果只记一个原则，就是：

电源设计必须在架构阶段做，而不是在布线阶段补。

## 纵向分析：PCB 电源设计问题怎么演进到现在

早期数字板的电源设计更多是 DC 问题。电压轨数量少，电流不大，逻辑速度也没有把边沿频谱推得很高。工程师关心的是线宽够不够、铜皮够不够、稳压器能不能带得动负载。那时的失效多是压降太大、局部发热、稳压器不稳定。

后来，高速数字和 BGA 把问题推进了一层。芯片 I/O 变多，核心电压下降，电流上升，BGA 焊球和过孔阵列把供电路径压缩到很小的区域。电源不再只看 DC IR drop，还要看瞬态电流经过有限电感时造成的电压塌陷。TI 的 66AK2G1x PDN 应用报告直接把 PCB 称为系统级 PDN 的关键部分，并把 stack-up、静态 IR drop、动态 PDN 分析和检查清单列为完整流程的一部分。

再往后，FPGA、SoC、GPU、AI 加速器和高速 SerDes 让电源轨数量继续增加。一个大器件可能有核心、I/O、PLL、收发器模拟电源、收发器终端电源、DDR、参考时钟、ADC/DAC 等多类轨。AMD 的 UG949 说明了自适应 SoC 的特殊性：不同用户设计、频率和时钟域会让功耗需求变化很大，因此需要用 XPE/PDM 等工具估算功耗，并在必要时做 PDN 仿真，而不能只拿通用电容表照抄。

当边沿速度继续提高后，板级电容的作用频段也被重新理解。Intel/Altera 的 AN 958 采用频域目标阻抗方法（FDTIM）来确定板级去耦需求。它的关键意思不是「电容越多越好」，而是：在目标频率范围内，让有效 PDN 阻抗低于目标阻抗。Intel 的 PDN 工具文档还明确指出，板级去耦电容在高频会被安装电感、平面扩散电感、BGA via 电感和封装寄生限制；再往上，更多依赖封装电容和片上电容。

现在，高速高密 PCB 的电源设计已经进入 PI/SI/thermal/reliability 联合问题阶段。电源噪声会转化成 SerDes 抖动，会调制 PLL/ADC/DAC，会通过返回路径影响串扰和 EMI，会通过局部电流密度影响温升和可靠性。Tektronix 的电源完整性资料把 PDN 定义为从 VRM 到芯片焊盘之间的完整互连系统，并强调电源轨噪声会影响高速数据线抖动。这个判断在工程上很重要：看眼图闭合或链路误码时，不能只查通道，也要查供电。

这个演进可以压缩成四个阶段：

| 阶段             | 核心问题                         | 典型设计动作                               | 典型漏项                 |
| ---------------- | -------------------------------- | ------------------------------------------ | ------------------------ |
| DC 供电阶段      | 电流够不够、压降大不大           | 线宽、铜厚、稳压器容量                     | 不看瞬态                 |
| 去耦经验阶段     | 局部开关电流导致电压波动         | 每个电源脚旁放 0.1 uF、加 bulk             | 不看 ESL/安装电感/反谐振 |
| PDN 目标阻抗阶段 | 在频域维持低阻抗                 | Ztarget、板级去耦、平面电容、仿真          | 把电容数量当目标         |
| 系统级 PI 阶段   | 电源噪声影响 SI、EMI、热和可靠性 | SI/PI 联合仿真、测量、功耗估算、sequencing | 架构后期才想电源         |

## 横向分析：高速高密 PCB 电源设计的主要问题

### 1. 电源架构：轨太多，不能只靠经验合并

高速高密板上最先出错的不是 layout，而是 power tree。轨的定义、合并、上电顺序、监测、裕量、负载分类没有想清楚，后面无论怎么堆电容都很难救。

常见问题：

- 核心电源、PLL/SerDes 模拟电源、I/O 电源、DDR 电源被过度合并。
- 只按稳压器电流能力选型，不按噪声、瞬态响应、远端 sense、环路稳定性选型。
- 没有为每路关键电源预留电流检测，导致样机阶段无法判断真实负载。
- 电源时序只靠 PMIC 默认配置，没有和芯片 data sheet 的 power-on/off sequence 对齐。
- 多个大负载共轨时，没有做 transfer impedance 和噪声传播评估。

AMD UG949 的建议很直接：先估算具体设计的功耗，选择满足噪声和电流要求的稳压器，必要时做 PDN 仿真，并建议增加 shunt resistor 或 PMBus/current monitor 来监测每路电源。

### 2. 目标阻抗：不要把「电容数量」当成设计目标

PDN 的基本目标是让负载电流变化时，电源轨电压仍留在允许范围内。工程上常用一阶估算：

```text
Ztarget = 允许电压波动 / 最大瞬态电流阶跃
```

这个公式简单，但它会迫使设计者问一个更重要的问题：负载到底会在多快的时间内拉多少电流？如果这个问题答不上来，电容表就只是在猜。

Intel/Altera AN 958 推荐用频域目标阻抗方法决定板级去耦。它还指出，目标频率通常到几十 MHz 到一两百 MHz 量级，再往上板级电容会因为平面扩散电感、封装安装电感等限制失效，主要靠封装和片上电容承担。

这对检查很关键。很多设计评审只问「0.1 uF 放够了吗」，但正确问题应该是：

- 每条关键电源轨的允许 ripple/noise 是多少？
- 最大瞬态电流阶跃来自哪里？FPGA fabric？DDR burst？SerDes CDR？ADC/DAC？
- VRM 在哪个频段开始变成感性？
- bulk、mid-frequency ceramic、平面电容、封装电容之间的频段接力是否连续？
- 是否出现高 Q 反谐振峰？

### 3. 去耦电容：位置和安装电感比标称容量更要命

去耦电容不是理想电容。TI 报告强调真实电容要按 RLC 看，包含 ESR 和 ESL；电容安装的 pad、trace、via 也会贡献电感和电阻。ADI 的 AN-1142 也提醒，简单撒很多不同容值并不等于低阻抗，选对值、类型和 stack-up 同样重要。

在高速高密板里，常见错误有：

- 电容离 BGA 太远，电容值看起来够，实际 loop inductance 太大。
- 多个电容共用一个 via，造成 via starvation 和共享阻抗。
- 电容一端用长细线接 power plane，另一端用长细线接 ground plane。
- 小封装电容没有靠近负载，高频去耦被安装电感吃掉。
- 盲目堆多种容值，产生反谐振峰，反而在某些频点抬高阻抗。

优先级应该是：

1. 先保证电源/地平面对靠近，形成低电感平面电容。
2. 再把高频/中频陶瓷电容放在 BGA 背面或最近可达位置。
3. 对每个关键电容尽量做到一电容一组 power/ground via。
4. 连接 trace 短、宽，via 靠 pad，条件允许时用 via-in-pad。
5. 最后才讨论电容值组合和 BOM 优化。

### 4. Stack-up：层叠不是机械约束，而是 PDN 的一部分

层叠决定了回流路径、电源-地平面电容、平面扩散电感、去耦 loop inductance 和 EMI。TI 建议 power/ground plane pair 要紧耦合、尽量 solid，并使用薄介质提高平面电容。Intel/Altera 也把 plane capacitance 作为高频去耦的重要方式，给出平行板电容模型：

```text
C = epsilon0 * epsilonr * A / h
```

这意味着增加重叠面积、减小平面间距、提高介电常数都会提高平面电容；但真正的工程收益不是电容数值本身，而是低电感、高频可用。

高速高密板的 stack-up 检查重点：

- 高优先级电源轨是否靠近芯片所在面？
- 核心电源和 GND 是否形成紧耦合平面对？
- 高速信号层是否有连续参考 GND？
- 大面积 plane split 是否切断回流路径？
- 电源岛边界是否靠近高速信号、参考时钟或敏感模拟线？
- BGA 区域是否因为逃逸布线打碎了电源/地平面？

### 5. BGA/HDI 供电：真正的瓶颈经常在 via field

高速高密板里，BGA 下面的供电路径是最容易被低估的区域。稳压器输出和大平面再好，如果进入 BGA 的 via 数不足、via 排布太差、反焊盘切碎参考平面，芯片焊球处仍然会掉压、噪声增大。

TI 报告专门提到 via starvation：当一个 via 或 via 网络无法供应足够电流时，就会成为供电瓶颈。因此高密 BGA 需要检查：

- 每个高电流 rail 从 plane 到 BGA ball 的 via 数量是否足够。
- via 的电流承载能力是否经过仿真或规则核算。
- 是否多颗电容共用同一过孔，造成共享阻抗。
- HDI 盲埋孔、via-in-pad、microvia stack 是否满足制造可靠性。
- BGA fanout 是否为了信号逃逸牺牲了关键电源/地通道。

一句话：BGA 供电不是看「铜皮面积」，而是看「从芯片焊球往外看见的阻抗」。

### 6. 开关电源布局：噪声源要被关在自己的区域里

开关电源的 layout 不只是效率问题，也是整板 PI/SI 问题。ADI 的 AN-136 强调，开关电源位置和布局要在早期规划；供电输出应靠近负载以降低互连阻抗和压降；敏感信号不要从电源开关区域下面穿过；多层板中可用内部地/电源层屏蔽小信号层。

高速高密板的常见错误：

- VRM 被挤到板边，离高电流负载太远。
- 输入高 di/dt 回路和输出高电流回路面积太大。
- SW node 铜皮为了散热铺得很大，结果成为强噪声天线。
- 补偿网络、FB 节点、remote sense 线被开关节点或大电流路径污染。
- 多相电源相位、布局和电流均流没有验证。

检查时要把电源分成三类区域：高 di/dt 热回路、低噪声反馈/补偿回路、输出大电流低阻抗路径。三者不能混在一起。

### 7. 敏感电源：PLL、SerDes、ADC/DAC、参考时钟不能粗暴共轨

高速高密 PCB 最怕把「电压一样」理解成「可以直接合并」。同样是 0.85 V 或 1.8 V，数字核心、SerDes 模拟、PLL、ADC/DAC、参考时钟缓冲器对噪声的敏感性完全不同。

AMD UG583 的 PS-GTR 检查表提到，PS_MGTRAVCC 这种 transceiver 供电不与其他非 transceiver 负载共享，可以降低超出噪声要求的风险，并给出电源噪声要求和滤波建议。这个思路可以推广到所有高速敏感轨：

- SerDes analog rail 优先独立或经滤波隔离。
- PLL/refclk 电源不要和大电流数字 rail 共阻抗。
- ADC/DAC 参考和模拟电源要按器件手册做局部去耦和低噪声供电。
- ferrite bead 不是万能隔离器，必须检查 DC 压降、饱和电流、阻抗频段和反谐振。
- 低噪声 LDO 能降低高频噪声，但热和 dropout 裕量要一起算。

### 8. 电源噪声会变成 SI 问题

电源噪声不只表现为 rail ripple。它会通过驱动器阈值、PLL/VCO、CDR、SerDes TX/RX、ADC aperture jitter 等路径变成时序噪声或幅度噪声。Tektronix 的资料指出，电源轨噪声会影响高速数据线 jitter，调试 SerDes 时应把电源和眼图、TIE spectrum、频谱一起看。

因此高速板调试时，如果看到：

- SerDes BER 偶发恶化；
- 眼图在某些模式下周期性收缩；
- PLL lock 不稳定；
- DDR margin 随负载变化；
- ADC spur 和某个电源开关频率相关；

不要只查阻抗、走线或固件，也要查 PDN 频谱、负载瞬态和共阻抗耦合。

## 横纵交汇洞察

### 洞察一：电源完整性不是去耦电容问题，而是阻抗路径问题

高速高密 PCB 的供电路径从 VRM 到 die，中间包含电感、电阻、电容和多级谐振。哪个环节阻抗最高，哪个环节就是瓶颈。电容标称值只是很小的一部分。

所以评审时不要问「每个电源脚有没有 0.1 uF」，而要问：

这个电源 rail 在芯片焊球处，从 DC 到目标频率范围内的阻抗曲线是什么样？

### 洞察二：高密设计里，空间分配就是电源设计

VRM 位置、电容位置、BGA 背面区域、power/ground plane pair、HDI via 通道都需要空间。等高速信号、连接器、结构件都摆完，再想把电源补进去，通常只能得到一个勉强可用但不可控的 PDN。

高密 PCB 里，最贵的资源不是电容，而是低电感路径。

### 洞察三：仿真和测量要闭环

仿真不是为了生成漂亮图，而是为了回答四个问题：

- DC IR drop 是否满足最坏负载？
- 动态负载下 package ball 电压是否在容限内？
- PDN 阻抗是否有危险反谐振峰？
- 噪声是否会通过 transfer impedance 传到敏感 rail？

测量也不是只拿示波器探一下 ripple。需要按 rail 逐项测 turn-on/off、overshoot、undershoot、ripple spectrum、负载阶跃响应、PDN impedance，必要时把 jitter/eye 和 rail noise 同步观察。

## 高速高密 PCB 电源设计检查清单

下面这份清单按项目阶段组织，可直接用于 schematic review、layout review、PI review 和 bring-up。

### A. 电源架构与规格

| 检查项                  | 判定标准                                                     |
| ----------------------- | ------------------------------------------------------------ |
| 电源轨清单完整          | 每个 IC rail 标明电压、容差、最大/典型电流、瞬态电流、噪声要求、上电顺序 |
| 负载分类完成            | 核心、I/O、DDR、SerDes、PLL、ADC/DAC、reference clock、always-on 分开标注 |
| power tree 明确         | 每路 VRM/LDO/PMIC 输出、合并关系、滤波关系、负载位置清楚     |
| 电源时序符合 data sheet | power-on/off sequence、reset release、PGOOD、enable 逻辑已核对 |
| 电源监测预留            | 关键 rail 有 shunt、PMBus、test point 或 current monitor     |
| 远端 sense 策略明确     | sense 点放在负载近端，走线 Kelvin，避免经过大电流路径        |
| 裕量定义清楚            | VRM ripple、load transient、DC IR drop、测量误差共同纳入 rail tolerance |

### B. VRM/PMIC/LDO 设计

| 检查项             | 判定标准                                                     |
| ------------------ | ------------------------------------------------------------ |
| VRM 电流能力足够   | 峰值、热降额、输入电压最差值、相数均流均检查                 |
| 瞬态响应满足负载   | step load、slew rate、undershoot/overshoot 经过仿真或供应商模型确认 |
| 环路稳定性验证     | bode/phase margin 或供应商推荐补偿网络确认                   |
| 输入电容靠近功率级 | 输入高 di/dt 回路面积最小                                    |
| SW node 受控       | 铜皮不过度扩大，远离敏感线、反馈线、参考时钟                 |
| FB/COMP 远离噪声   | 反馈和补偿节点短、干净，有 GND shielding                     |
| LDO 热设计通过     | dropout、功耗、铜皮散热、环境温度 worst case 已计算          |

### C. Stack-up 与平面

| 检查项                      | 判定标准                                                     |
| --------------------------- | ------------------------------------------------------------ |
| 高优先级 rail 靠近器件面    | 核心/大电流 rail 在 stack-up 上半区或靠近芯片侧              |
| power/GND plane pair 紧耦合 | 介质尽量薄，平面重叠面积足够                                 |
| GND 平面连续                | 高速信号参考层下方没有长缝、割裂或孤岛                       |
| 电源岛边界受控              | 高速信号不跨电源岛边界；必要时用 stitching caps/return vias  |
| 平面电容纳入 PI             | 不只算离散电容，也看 plane capacitance 和 spreading inductance |
| 大电流 plane 有热裕量       | 铜厚、温升、过孔、连接颈缩已检查                             |

### D. BGA/HDI 供电路径

| 检查项                 | 判定标准                                           |
| ---------------------- | -------------------------------------------------- |
| BGA power via 数量足够 | 每个高电流 rail 有足够 via，避免 via starvation    |
| GND via 密度足够       | 高速和电源返回路径都有低阻抗 GND 通道              |
| 电容 via 不共享        | 关键去耦尽量一颗电容一组独立 power/GND via         |
| BGA 背面去耦区保留     | 核心 rail 高频/中频去耦优先放在芯片背面            |
| via-in-pad 工艺可控    | 填孔、电镀、平整度、可靠性和成本已确认             |
| fanout 不破坏平面      | BGA escape 没有把关键 power/GND plane 打碎         |
| HDI 堆叠可靠性检查     | stacked microvia、skip via、埋孔结构经过制造商确认 |

### E. 去耦网络

| 检查项             | 判定标准                                                     |
| ------------------ | ------------------------------------------------------------ |
| 每 rail 有目标阻抗 | Ztarget = 允许 ripple / 最大瞬态电流阶跃                     |
| 频段分工明确       | VRM、bulk、mid-frequency ceramic、plane、package/on-die 电容各自覆盖频段清楚 |
| 电容模型真实       | 使用含 ESR/ESL/SRF 的模型，不只用理想 C                      |
| 反谐振峰检查       | 不同容值组合没有形成高 Q 阻抗峰                              |
| 安装电感最小       | 短宽连接、via 靠 pad、必要时双 via 或 via-in-pad             |
| 电容位置分层       | bulk 在电源入口或 VRM 输出，中频/高频靠近负载                |
| BOM 可制造         | 封装尺寸、耐压、DC bias、温度系数、可采购性检查              |

### F. 敏感轨隔离

| 检查项                      | 判定标准                                             |
| --------------------------- | ---------------------------------------------------- |
| PLL/refclk rail 隔离        | 不与大电流数字负载共享高阻抗路径                     |
| SerDes analog rail 独立评估 | ripple/noise、滤波、去耦和共轨风险单独检查           |
| ADC/DAC rail 按手册布局     | reference、analog、clock 供电去耦和地回流明确        |
| ferrite bead 合理           | 阻抗频段、DC 电流、压降、饱和、热和反谐振已检查      |
| LDO 噪声和 PSRR 匹配        | 开关频率及其谐波落在 LDO 有效抑制范围内              |
| 噪声源空间隔离              | VRM、inductor、SW node 远离模拟、时钟、SerDes refclk |

### G. 仿真与分析

| 检查项             | 判定标准                                                    |
| ------------------ | ----------------------------------------------------------- |
| DC IR drop         | 最坏电流、温度、电阻率、铜厚、via 数量下通过                |
| 电迁移/电流密度    | plane、neck-down、via、connector pin 不超限                 |
| PDN 阻抗           | 芯片焊球处 Z(f) 低于目标阻抗，频段定义合理                  |
| Transfer impedance | 多负载共轨、噪声源到敏感 rail 的耦合已评估                  |
| Load transient     | VRM + PCB + package 组合瞬态响应满足容限                    |
| SI/PI 联合         | SerDes/DDR/clock 的 jitter、eye、BER 与 rail noise 关联检查 |
| 热仿真             | VRM、LDO、inductor、connector、BGA 下方热点检查             |

### H. Layout 细节

| 检查项            | 判定标准                                               |
| ----------------- | ------------------------------------------------------ |
| 大电流路径短宽    | VRM 到负载和输出电容路径低阻低感                       |
| 高 di/dt 回路最小 | buck 输入电容、FET、inductor 回路面积受控              |
| 反馈线 Kelvin     | FB/sense 线不与大电流路径共享铜                        |
| 测试点可用        | 每路关键 rail 有靠近负载的低电感测量点                 |
| 分割平面谨慎      | 不在高速信号下方开缝，不制造长窄电源颈                 |
| 热过孔充足        | LDO、PMIC、power module、EPAD 有足够 GND/thermal via   |
| 装配规则通过      | 电容太密、via-in-pad、BGA 背面器件高度和可返修性已确认 |

### I. 样机 Bring-up 与测量

| 检查项            | 判定标准                                             |
| ----------------- | ---------------------------------------------------- |
| 上电顺序实测      | 每路 rail ramp、PGOOD、reset release 波形记录        |
| 静态电流对比      | 实测电流与估算/仿真差异解释清楚                      |
| ripple/noise 测量 | 用低噪声电源探头或 50 ohm 方法，避免长地线探头       |
| 负载阶跃测试      | 对核心 rail、DDR rail、SerDes rail 做动态响应测试    |
| 频谱分析          | ripple 频率与 VRM switching、clock、SerDes spur 关联 |
| 眼图/抖动关联     | 高速链路问题同步看 rail noise 和 jitter/TIE          |
| 温升记录          | 满载、环境高温、风扇失效或低风量场景下确认           |

## 最容易翻车的 12 个点

1. 电源轨合并只看电压，不看噪声敏感性。
2. VRM 放得太远，输出电容离负载也远。
3. BGA 背面空间被信号/结构占掉，关键去耦放不进去。
4. 多个电容共用 via，表面看电容多，实际共享电感大。
5. 盲目堆不同容值，产生反谐振峰。
6. power/GND plane pair 间距太大，高频平面电容不足。
7. 高速信号跨过电源岛或地平面开缝。
8. ferrite bead 用来隔离敏感轨，但没检查饱和、压降和反谐振。
9. 只做 DC IR drop，不做动态 PDN。
10. 样机测 ripple 用长地线普通探头，测到的是探头回路噪声。
11. SerDes/DDR margin 出问题只查 SI，不查供电噪声。
12. 电源设计最后才介入，低电感路径已经没有空间。

## 结论

高速高密 PCB 的电源设计，本质上是一个跨频段、跨结构、跨学科的阻抗控制问题。低频靠 VRM，中频靠 bulk 和陶瓷电容，高频靠平面电容、封装电容和片上电容；DC 看 IR drop，AC 看目标阻抗，系统层面还要看噪声如何通过 PDN 影响 SI、EMI、热和可靠性。

我的工程建议是把电源设计拆成三条主线同步推进：

第一条是架构线：power tree、轨合并、时序、监测、VRM/LDO 选择。

第二条是物理线：stack-up、plane pair、BGA/HDI via、电容位置、低电感路径。

第三条是验证线：DC IR drop、PDN impedance、load transient、transfer impedance、样机测量和高速链路关联调试。

只要这三条线没有同时闭合，所谓「电源设计完成」就只是原理图完成，不是工程完成。

## 信息来源

- Intel/Altera, AN 958 Board Design Guidelines, Target Impedance Decoupling Method: https://docs.altera.com/r/docs/683073/current/an-958-board-design-guidelines/target-impedance-decoupling-method
- Intel/Altera, AN 958 Board Design Guidelines, Determining fTARGET: https://docs.altera.com/r/docs/683073/current/an-958-board-design-guidelines/determining-the-ftarget
- Intel/Altera, AN 958 Board Design Guidelines, Plane Capacitance: https://docs.altera.com/r/docs/683073/current/an-958-board-design-guidelines/plane-capacitance
- Intel/Altera, AN 958 Board Design Guidelines, Minimization Parasitic Inductances: https://docs.altera.com/r/docs/683073/current/an-958-board-design-guidelines/minimization-parasitic-inductances
- AMD, UG949 UltraFast Design Methodology Guide, Power Distribution System: https://docs.amd.com/r/en-US/ug949-vivado-design-methodology/Power-Distribution-System
- AMD, UG949, Power Supply Paths on Devices: https://docs.amd.com/r/en-US/ug949-vivado-design-methodology/Power-Supply-Paths-on-Devices
- AMD, UG583 UltraScale Architecture PCB Design User Guide, PCB Design Checklist: https://docs.amd.com/r/en-US/ug583-ultrascale-pcb-design/PCB-Design-Checklist
- Texas Instruments, 66AK2G1x: EVMK2GX General-Purpose EVM Power Distribution Network Analysis, SPRACE6: https://www.ti.com/lit/an/sprace6/sprace6.pdf
- Analog Devices, AN-136 PCB Layout Considerations for Non-Isolated Switching Power Supplies: https://www.analog.com/en/resources/app-notes/an-136.html
- Analog Devices, AN-1142 Techniques for High Speed ADC PCB Layout: https://www.analog.com/en/resources/app-notes/an-1142.html
- Analog Devices, Basic Guidelines for Layout Design of Mixed-Signal PCBs: https://www.analog.com/en/resources/analog-dialogue/articles/what-are-the-basic-guidelines-for-layout-design-of-mixed-signal-pcbs.html
- Tektronix, Analyzing Power Integrity on a Power Distribution Network: https://www.tek.com/application/analyzing-power-integrity-on-pdns
- Tektronix, Using Mixed Signal Oscilloscopes to Find and Diagnose Jitter Caused by Power Integrity Problems: https://www.tek.com/en/documents/application-note/using-mixed-signal-oscilloscopes-to-find-and-diagnose-jitter-caused-by-power-integrity-problems

## 中英术语对照表

| 中文术语         | 英文术语 / 缩写                   | 说明                                                     |
| ---------------- | --------------------------------- | -------------------------------------------------------- |
| 印制电路板       | Printed Circuit Board, PCB        | 承载器件、走线、平面和过孔的板级互连平台                 |
| 电源分配网络     | Power Distribution Network, PDN   | 从稳压器到芯片焊球/管脚的完整供电网络                    |
| 电源分配系统     | Power Distribution System, PDS    | 与 PDN 接近，常用于 FPGA/SoC 厂商文档                    |
| 电源完整性       | Power Integrity, PI               | 关注电源噪声、压降、阻抗、瞬态响应和稳定性的工程领域     |
| 信号完整性       | Signal Integrity, SI              | 关注高速信号波形、阻抗、反射、串扰、抖动和误码的工程领域 |
| 电磁干扰         | Electromagnetic Interference, EMI | 电磁噪声对本系统或外部系统造成的干扰                     |
| 电源轨           | Power Rail                        | 某一路具体供电网络，例如 0.85 V core rail                |
| 稳压模块         | Voltage Regulator Module, VRM     | 把输入电源转换成目标电压的稳压电源模块                   |
| 电源管理芯片     | Power Management IC, PMIC         | 集成多路稳压、时序、监测和保护的电源管理器件             |
| 低压差线性稳压器 | Low-Dropout Regulator, LDO        | 常用于低噪声或局部二级稳压的线性稳压器                   |
| 降压转换器       | Buck Converter                    | 常见开关电源拓扑，把高电压转换成低电压                   |
| 开关节点         | Switching Node, SW Node           | Buck 中电压高速切换的节点，是强噪声源                    |
| 电源良好信号     | Power Good, PGOOD                 | 表示某路电源已进入有效范围的状态信号                     |
| 远端采样         | Remote Sense                      | 在负载近端采样电压，补偿供电路径压降                     |
| 开尔文连接       | Kelvin Connection                 | 电流路径和电压采样路径分开，降低测量/反馈误差            |
| 目标阻抗         | Target Impedance, Ztarget         | 为满足允许电压波动而设定的 PDN 阻抗上限                  |
| 直流压降         | DC IR Drop                        | 直流电流流过电阻路径造成的电压下降                       |
| 负载瞬态         | Load Transient                    | 负载电流快速变化时电源轨的动态响应                       |
| 传递阻抗         | Transfer Impedance                | 一个节点的噪声通过 PDN 耦合到另一个节点的阻抗表征        |
| 去耦电容         | Decoupling Capacitor              | 为负载瞬态提供局部电荷、降低局部阻抗的电容               |
| 大容量电容       | Bulk Capacitor                    | 主要覆盖低频/中低频能量需求的大容量电容                  |
| 等效串联电阻     | Equivalent Series Resistance, ESR | 电容等效模型中的串联电阻                                 |
| 等效串联电感     | Equivalent Series Inductance, ESL | 电容及其安装路径的等效串联电感                           |
| 自谐振频率       | Self-Resonant Frequency, SRF      | 电容阻抗由容性转为感性的频率点                           |
| 反谐振           | Anti-Resonance                    | 多个电容/平面组合在某些频点形成的阻抗尖峰                |
| 平面电容         | Plane Capacitance                 | 电源平面和地平面之间形成的分布电容                       |
| 电源/地平面对    | Power/Ground Plane Pair           | 紧邻的电源平面和地平面组合，用于降低 PDN 电感            |
| 层叠             | Stack-up                          | PCB 各信号层、介质层、电源层和地层的排列结构             |
| 扇出             | Fanout                            | BGA/密脚器件从焊盘逃逸到可布线区域的连接方式             |
| 球栅阵列封装     | Ball Grid Array, BGA              | 以焊球阵列作为外部连接的封装形式                         |
| 高密度互连       | High Density Interconnect, HDI    | 使用微孔、细线宽线距、多阶孔等实现高密布线的 PCB 技术    |
| 过孔             | Via                               | 连接不同 PCB 层的垂直导通结构                            |
| 微孔             | Microvia                          | HDI 中常见的小尺寸激光孔                                 |
| 盘中孔           | Via-in-Pad                        | 过孔直接放在焊盘内的工艺                                 |
| 过孔不足         | Via Starvation                    | 供电/回流过孔数量或位置不足导致路径阻抗过高              |
| 电流密度         | Current Density                   | 单位截面积承载的电流，关系到温升和可靠性                 |
| 电迁移           | Electromigration                  | 金属中原子受电流推动迁移造成的长期可靠性问题             |
| 铁氧体磁珠       | Ferrite Bead                      | 常用于电源隔离和高频噪声抑制的无源器件                   |
| 反馈节点         | Feedback Node, FB                 | 稳压器用于采样输出电压的反馈节点                         |
| 补偿网络         | Compensation Network, COMP        | 稳压器环路稳定性相关的补偿电路                           |
| 串行器/解串器    | Serializer/Deserializer, SerDes   | 高速串行通信接口的收发结构                               |
| 双倍数据率存储器 | Double Data Rate, DDR             | 常见高速存储接口类型                                     |
| 锁相环           | Phase-Locked Loop, PLL            | 用于时钟产生、恢复和频率合成的电路                       |
| 模数/数模转换器  | ADC/DAC                           | 模拟-数字转换器 / 数字-模拟转换器                        |
| 参考时钟         | Reference Clock, Refclk           | 为高速接口或时钟系统提供基准的时钟信号                   |
| 纹波/噪声        | Ripple / Noise                    | 电源轨上周期性或随机性的电压扰动                         |
| 抖动             | Jitter                            | 信号边沿在时间位置上的偏移                               |
| 眼图             | Eye Diagram                       | 评估高速链路波形裕量的叠加图形                           |
| 误码率           | Bit Error Rate, BER               | 数据传输中错误 bit 占总 bit 的比例                       |
| 时间间隔误差     | Time Interval Error, TIE          | 实际边沿与理想边沿之间的时间误差                         |
| 调试上电         | Bring-up                          | 样机首次上电、验证和问题定位过程                         |
| 电源管理总线     | Power Management Bus, PMBus       | 用于电源配置、遥测和控制的数字管理接口                   |
| 热过孔           | Thermal Via                       | 用于把热量导到内层或背面的过孔                           |
| 噪声裕量         | Noise Margin                      | 系统在不出错前可承受的噪声余量                           |
