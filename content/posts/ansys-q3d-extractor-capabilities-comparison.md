+++
title = "别把 Q3D 当 HFSS：Ansys Q3D Extractor 的能力边界与竞品比较"
date = 2026-05-01T20:00:00+08:00
draft = false
slug = "ansys-q3d-extractor-capabilities-comparison"
description = "Ansys Q3D Extractor 的能力、特点、适用场景、使用技巧，以及与 HFSS、SIwave、Cadence Sigrity、Keysight ADS/PEPro 等工具的比较。"
tags = ["Q3D", "Ansys", "Electromagnetic Simulation", "SI", "PI", "PCB", "封装", "寄生参数提取"]
categories = ["教程"]
columns = ["电磁仿真"]

+++

# Ansys Q3D Extractor 能力、特点、适用场景与竞品比较

> 研究时间：2026-05-01  
> 研究对象：Ansys Q3D Extractor、寄生参数提取、RLCG 建模、PCB/封装/电力电子互连仿真  
> 方法：横纵分析法

## 一句话判断

Ansys Q3D Extractor 的核心价值不是「仿真所有电磁问题」，而是把复杂三维互连结构里的寄生电阻、电感、电容、电导提取成可用于电路仿真的模型。它最擅长回答的问题是：这段导体、过孔、bond wire、busbar、connector、package lead、RDL 或电源回路到底带来了多少 R、L、C、G，以及这些寄生参数会怎样影响 SI、PI、开关尖峰、振铃、串扰、ground bounce 和系统级电路行为。

如果把 Ansys 电磁工具链粗略分工，Q3D 更像「寄生参数显微镜」，HFSS 更像「全波电磁显微镜」，SIwave 更像「PCB/封装级 SI/PI 工作流工具」。Q3D 的强项是低频到中高频、结构尺寸相对波长较小、以 lumped/distributed equivalent model 为目标的互连提取；它的弱项是辐射、谐振、天线、复杂全波传播和完整系统级高速合规签核。

## 纵向分析：Q3D 为什么会有存在价值

电子设计最早对寄生参数的理解很朴素：导线有电阻，长线有电感，两个金属面之间有电容。低速电路时代，这些寄生参数往往只是误差项。到了高频、高速、高功率时代，它们变成了主角。

在高速数字里，封装引脚、电源地过孔、连接器、BGA ball、bond wire、差分过孔、RDL、TSV、plane cutout 都会影响眼图、串扰、反射和电源噪声。

在电力电子里，busbar、IGBT/SiC 模块、DC-link 回路、母排叠层、并联功率器件、开关回路寄生电感，会直接决定过压尖峰、振铃、EMI、开关损耗和器件可靠性。

问题是这些寄生参数很难靠手算准确得到。手算适合简单平行板、圆线、电感环路；真实结构有三维几何、非均匀介质、多导体耦合、skin effect、proximity effect、接触电阻和复杂回流路径。Q3D 这类工具的意义就在这里：用准静态场求解器把几何变成 RLCG 矩阵，再导出为 SPICE、IBIS package model 或其他电路模型，让寄生参数进入系统级仿真。

Ansys 官方对 Q3D 的定位很清楚：它执行 3D 和 2D quasi-static electromagnetic field simulation，用于从互连结构中提取 RLCG 参数；适用于 advanced electronics packages、connectors、high-power bus bars、power converter components 等。2024 R1 增加了 CG 的 distributed memory solver 和 large package 的 AC-RL solver；2025 R1 又加入增强 source definitions、contact resistance modeling 和 radiated field analysis beta。这说明 Q3D 的演进方向不是替代 HFSS，而是继续把寄生提取做得更大、更快、更贴近电源完整性和封装互连。

Q3D 的演进可以这样理解：

| 阶段 | 工程需求 | Q3D 角色 |
|---|---|---|
| 经验寄生阶段 | 手算估算导线/焊盘/封装寄生 | 提供更准确的三维 RLC 提取 |
| 高速封装阶段 | package、connector、bond wire、BGA 耦合影响 SI | 输出 SPICE/IBIS 模型给 SI 仿真 |
| 电力电子阶段 | busbar 和功率回路寄生电感决定过压/EMI | 优化回路电感、电阻、耦合和电热应力 |
| 多物理/系统阶段 | 寄生参数要进入 Twin Builder、Icepak、Mechanical、HFSS/SIwave 流程 | 成为 AEDT 里的互连寄生提取节点 |

## Q3D 的核心能力

### 1. 3D 准静态寄生参数提取

Q3D 的核心是 3D quasi-static field solver。Ansys 官方说明中提到，其 3D solver 基于 Method of Moments，并由 Fast Multipole Method 加速；结果包括 proximity effect、skin effect、dielectric/ohmic loss 和 frequency dependency。它能提取：

- R：电阻，包含频率相关 AC resistance；
- L：电感，通常包括 self/partial/mutual inductance；
- C：电容，多导体之间的 capacitance matrix；
- G：电导，介质损耗和泄漏路径相关。

这四类参数合起来就是 RLCG。工程上，它可以把复杂的三维金属结构变成电路仿真器能读懂的模型。

### 2. 2D Extractor：传输线和线缆截面

Q3D 不只是三维实体提取，也包含 2D Extractor。Ansys 官方说明中提到，2D Extractor 使用 FEM 求 cable、transmission line 的 per-unit-length RLCG、Z0 matrix、propagation speed、delay、attenuation、effective permittivity、differential/common-mode 参数，以及 near/far-end crosstalk coefficients。

这部分适合做：

- 微带线/带状线截面；
- 差分线 cross-section；
- 线缆截面；
- 多导体传输线；
- 简化而规则的长线结构。

简单说，结构沿长度方向比较规则，用 2D；局部三维结构复杂，用 3D。

### 3. 等效电路模型输出

Q3D 的目标通常不是生成漂亮场图，而是输出可用模型。Ansys 官方列出的常见输出包括 Simplorer SML、HSPICE Tabular W-Element、PSpice、Spectre、IBIS ICM/PKG 和 Ansys CPP 等。

这意味着 Q3D 可以服务于：

- SPICE 电路仿真；
- IBIS package model；
- SerDes/channel 仿真；
- 功率开关瞬态仿真；
- Twin Builder/Simplorer 系统仿真；
- 封装/板级寄生模型交付。

### 4. 自适应网格和参数化优化

Q3D 和 Ansys Electronics Desktop 里的其他电磁工具一样，强调 automatic adaptive meshing。对用户来说，这降低了手动网格调参门槛，但不等于不需要工程判断。你仍然要定义正确的 net、source、sink、return path、材料、频率范围和收敛目标。

Q3D 也支持 Optimetrics 做参数化扫描和优化。典型变量包括：

- busbar 间距；
- 叠层厚度；
- 铜厚；
- via 数量；
- bond wire 数量和形状；
- terminal 位置；
- power/ground return path；
- package lead frame 形状。

## 适用场景

### 1. 电力电子和母排设计

这是 Q3D 非常典型的优势场景。Ansys 官方也把 high-power bus bars、power converter components、inverter/converter architectures 放在重点应用里。

典型问题：

- DC-link 回路寄生电感多大？
- IGBT/SiC 模块开关时会产生多大过压尖峰？
- 并联器件电流是否均流？
- 正负母排叠层如何降低 loop inductance？
- 端子位置怎么改能降低 mutual coupling？
- busbar AC resistance 和 proximity effect 是否导致额外损耗？

Q3D 在这里比 HFSS 更顺手，因为目标不是辐射场或天线效率，而是回路 L/R/C 的准确提取和电路模型输出。

### 2. 封装、连接器、bond wire、lead frame

Q3D 适合提取封装内的关键互连寄生：

- bond wire self/mutual inductance；
- lead frame resistance/inductance；
- package pin/ball parasitics；
- connector pin coupling；
- socket/contact parasitics；
- BGA ball 和 escape transition 的局部 RLC。

对于 IBIS package model，Q3D 很实用。Ansys 官方也明确提到它可生成 reduced-order SPICE models 和 IBIS package models，用于研究 crosstalk、ground bounce、interconnect delay 和 ringing。

### 3. PCB 局部结构和关键 nets

Q3D 不适合把整块大 PCB 当成完整系统来跑，但适合抽取局部关键结构：

- 高速过孔 transition；
- 电源过孔阵列；
- connector launch；
- BGA breakout；
- 分流电阻/电流采样结构；
- 局部 plane neck-down；
- 敏感模拟前端的寄生电容；
- 高频电流回路。

如果目标是完整 PCB 的 PDN impedance、DDR/SerDes 虚拟合规、全板 EMI scanning，SIwave 或 Cadence/Keysight/Siemens 的 SI/PI 平台通常更合适。

### 4. 传感器、电容触摸屏和薄导体结构

Ansys 官方列了 touchscreen design 作为 Q3D 应用之一，尤其是 ITO 等薄导电层。这里的目标往往是电容矩阵、触摸电极之间的耦合，以及电极形状优化。

### 5. 系统级电路模型前处理

Q3D 也常作为「模型生成器」存在：先在 Q3D 中提取寄生，再把模型带到 SPICE/Twin Builder/ADS/Simplorer 里做系统仿真。

这适合：

- 功率开关瞬态；
- EMI/EMC 前期评估；
- gate loop/source loop 寄生影响；
- package-board co-simulation；
- 热-电-机械链路中的电损耗输入。

## 适用技巧

### 1. 先定义问题，不要先导入复杂模型

Q3D 最常见的误用，是把完整 STEP/PCB/封装模型直接丢进去，然后期待自动得到正确答案。寄生参数提取不是渲染模型，关键是定义你要提取哪几个 conductor 之间的关系。

建模前先问：

- 我关心 R、L、C、G 里的哪几个？
- 关心 DC，还是某个频段的 AC？
- 结果要给 SPICE、IBIS、Twin Builder，还是只做几何优化？
- return path 是哪里？
- terminal/source/sink 应该放在哪里？
- 哪些小结构必须保留，哪些可以简化？

### 2. terminal 和 return path 比网格更重要

Q3D 结果对 terminal 定义非常敏感。尤其是电感，partial inductance 很容易被误读。如果没有明确回流路径，你得到的 L 值可能不对应真实电路回路。

技巧：

- 电力电子中，用实际电流进入和流出的端子定义 source/sink；
- 高速封装中，signal 旁边的 reference/ground 必须一并建模；
- 多导体结构中，明确谁是 signal、谁是 return、谁是 floating；
- 比较方案时保持 terminal 定义一致，否则结果不可比；
- 对电感结果，优先关注 loop inductance 和 mutual coupling，而不是孤立 self L。

### 3. 几何简化要保留电流路径

可以删掉倒角、螺丝细节、丝印、外壳装饰，但不能随意删掉电流拥挤区、窄颈、接触面、过孔、焊盘、bond wire、端子。

好的简化原则：

- 对 R：保留电流密度变化剧烈的 neck-down、contact、via、薄铜区域；
- 对 L：保留回路面积、导体间距、return conductor；
- 对 C：保留相邻导体面积、介质厚度、屏蔽结构；
- 对 G：保留介质材料和损耗路径。

### 4. 频率范围要和物理问题匹配

Q3D 可以提取 frequency-dependent R/L/C/G，但它是准静态方法。不要把它当成所有高频电磁传播问题的全波替代品。

经验判断：

- 结构尺寸远小于波长，目标是寄生 RLCG：Q3D 合适；
- 结构出现明显传播、谐振、辐射、天线效应：转 HFSS/Clarity/CST/Feko；
- 完整 PCB/封装 SI/PI 签核：优先 SIwave/Sigrity/HyperLynx/SIPro/PIPro 这类流程化工具；
- 低频电机、磁性器件、运动和非线性磁材：Maxwell 或 COMSOL AC/DC 更合适。

### 5. 用简单结构校准直觉

Q3D 初学者最容易被矩阵表格淹没。建议先用简单结构做 sanity check：

- 平行板电容；
- 单根导体回路；
- 两根平行母排；
- 差分线截面；
- 单个 via 与返回 via；
- 两根 bond wire。

先让仿真结果和手算/经验量级对上，再进入复杂结构。

### 6. 输出模型前先看矩阵和能量分布

不要只导出 SPICE 就结束。至少检查：

- R/L/C/G 矩阵是否对称、量级是否合理；
- mutual coupling 的正负和大小是否符合几何直觉；
- 电流密度是否集中在不该集中的地方；
- terminal 附近有没有不合理热点；
- 频率 sweep 中是否出现不合理跳变；
- 减阶模型是否保留目标频段行为。

## Q3D 和 Ansys 自家工具的边界

| 工具 | 核心定位 | 适合问题 | 不适合作为首选的问题 |
|---|---|---|---|
| Q3D Extractor | 准静态 RLCG 寄生提取 | busbar、封装、connector、bond wire、局部 PCB 结构、电路模型输出 | 天线、辐射、全波谐振、完整高速通道签核 |
| HFSS | 3D full-wave EM signoff | 高频互连、天线、连接器、封装/PCB 全波、EMI/EMC、辐射和谐振 | 只想快速得到低频 RLCG 矩阵的小结构 |
| SIwave | PCB/封装 SI/PI/EMI 专用流程 | 完整 PCB/封装 PDN、SerDes/DDR、decap、crosstalk/EMI scanning、virtual compliance | 单个机械三维母排或任意 3D 实体寄生提取 |
| Maxwell | 低频电磁和机电设备 | 电机、变压器、无线充电、磁性器件、瞬态磁场、非线性磁材 | 高速封装/PCB RLCG 提取 |
| Icepak/Mechanical | 热/结构 | 电热、热应力、可靠性 | 单独求电磁寄生参数 |

一个实用流程是：

- 小结构寄生参数：Q3D；
- 同一结构高频辐射/谐振校验：HFSS；
- 整板/封装 SI/PI：SIwave；
- 功率器件热：Icepak；
- 热应力和机械可靠性：Mechanical；
- 系统级电路和控制：Twin Builder。

## 竞品比较

### 1. Cadence Sigrity X / Clarity

Cadence 的强项在 PCB/IC package 设计流程整合。Sigrity X 面向 SI/PI analysis、PDN analysis、in-design interconnect modeling，并与 Allegro X PCB/APD 平台深度集成。Cadence Clarity 3D Solver 则是 full-wave 3D EM solver，面向 PCB、IC package、SoIC 等复杂高频系统，强调 distributed multiprocessing、capacity 和 signoff accuracy。

和 Q3D 相比：

- Q3D 更偏独立的 3D/2D 寄生 RLCG 提取；
- Sigrity 更偏完整 SI/PI 工作流和 Allegro 生态；
- Clarity 更像 HFSS 的直接竞品，不是 Q3D 的直接竞品；
- Cadence XtractIM 与 Q3D 在 package RLC/IBIS/SPICE model extraction 上更接近。

如果团队使用 Allegro/APD 做 PCB/封装，Sigrity/XtractIM/Clarity 的流程优势很明显；如果团队在 AEDT/Ansys 生态里做多物理和电力电子，Q3D 更自然。

### 2. Keysight SIPro / PIPro / EMPro

Keysight 的特点是和 ADS、高速通道仿真、测试测量生态结合很深。SIPro 面向 high-speed PCB 的 SI EM analysis，可提取 loss/coupling 并转入 ADS transient/channel simulation；PIPro 面向 PDN 的 DC IR drop、AC impedance、电热 DC、decap optimization 和 power plane resonance；EMPro 则是更通用的 3D EM 环境。

和 Q3D 相比：

- Q3D 适合任意三维互连结构的 RLCG 参数提取；
- SIPro/PIPro 更像面向 PCB SI/PI 的流程化工具；
- ADS 生态下做 SerDes/channel/measurement correlation，Keysight 很强；
- 电力电子 busbar/功率模块寄生提取，Q3D 的定位更直接。

### 3. Siemens HyperLynx Advanced Solvers

Siemens HyperLynx Advanced Solvers 提供 full-wave、hybrid、quasi-static 三类 EM 解法。官方说明里对边界划得很清楚：结构远小于波长时 quasi-static 足够；大而规则的平面/传输线结构可用 hybrid；高频且精度要求高时用 full-wave。

这套逻辑和 Q3D/HFSS/SIwave 的分工很像。HyperLynx 的优势是 PCB 流程和 progressive verification，对设计工程师比较友好；Q3D 的优势是任意三维结构 RLCG 提取和 Ansys 多物理生态。

### 4. COMSOL AC/DC Module

COMSOL AC/DC Module 是低频电磁和多物理平台的一部分。官方说明中提到它可以做 Electric Currents、Electrostatics、Magnetostatics，并且有 parasitic inductance and parameter extraction 方法，适用于 PCB 中 large inductance matrices 等问题。

和 Q3D 相比：

- COMSOL 的优势是多物理灵活性、方程可控、热/结构/流体耦合自由度高；
- Q3D 的优势是电子互连 RLCG 提取流程更专用、模型输出更面向电路仿真；
- 研究型、自定义物理问题可选 COMSOL；
- 工程化 package/busbar parasitic extraction 可优先 Q3D。

### 5. CST Studio Suite / Altair Feko

CST Studio Suite 和 Altair Feko 更偏广义 3D EM/full-wave 平台。CST 提供跨 EM spectrum 的多求解器；Feko 强在天线、EMC/EMI、RCS、无线连接、复杂大尺寸结构和 hybridized solvers。

和 Q3D 相比：

- CST/Feko 更适合天线、辐射、EMC、RCS、无线和全波传播；
- Q3D 更适合小结构寄生参数矩阵和电路模型输出；
- 如果关心「这个 busbar 的 loop inductance 是多少」，Q3D 更直接；
- 如果关心「这个系统对外辐射多少、天线效率如何」，CST/Feko/HFSS 更合适。

## 横向对比总表

| 工具 | 求解定位 | 强项 | 相对 Q3D 的差异 |
|---|---|---|---|
| Ansys Q3D Extractor | 2D/3D quasi-static RLCG extraction | 寄生 RLCG、SPICE/IBIS、busbar、package、connector | 本报告主角，偏寄生提取 |
| Ansys HFSS | 3D full-wave EM | 高频互连、辐射、天线、全波 signoff | 更准确但更重，适合高频传播/谐振 |
| Ansys SIwave | PCB/package SI/PI workflow | 整板 PDN、SerDes/DDR、decap、EMI scanning | 更流程化，适合全板/封装签核 |
| Cadence Sigrity X | SI/PI platform | Allegro 生态、in-design SI/PI、PDN、package | 流程整合强，偏 PCB/package 平台 |
| Cadence Clarity | 3D full-wave EM | PCB/package/SoIC full-wave，分布式大容量 | 更接近 HFSS |
| Keysight SIPro/PIPro | ADS SI/PI EM workflow | ADS channel、measurement correlation、PDN | 高速通道/测试生态强 |
| Siemens HyperLynx Advanced Solvers | full-wave/hybrid/quasi-static | PCB progressive verification、SI/PI 自动化 | 设计工程师友好，PCB 流程强 |
| COMSOL AC/DC | low-frequency EM multiphysics | 自定义物理、多物理耦合、研究型问题 | 灵活但电子互连专用流程较弱 |
| CST Studio Suite | multi-solver 3D EM | 全波、EMC/EMI、天线、封装/RF | 更偏广义全波平台 |
| Altair Feko | high-frequency CEM | 天线、EMC、RCS、大尺寸结构 | 不是 RLCG 提取主力 |

## 选择建议

### 优先选 Q3D 的情况

- 你要的是 R、L、C、G 矩阵；
- 你要导出 SPICE/IBIS package model；
- 你在做 busbar、power module、connector、bond wire、lead frame；
- 你关心低频到中高频寄生，而不是辐射；
- 结构是局部三维互连，而不是完整系统；
- 你已经在 Ansys AEDT/Twin Builder/Icepak/HFSS 流程里。

### 不要优先选 Q3D 的情况

- 你要做天线方向图、辐射效率、RCS；
- 你要完整高速通道 full-wave signoff；
- 你要整板 DDR/SerDes 合规自动化；
- 你要预测 EMC 辐射发射；
- 结构尺寸已经接近波长，传播效应非常明显；
- 你需要完整系统级 SI/PI 工作流而不是局部寄生提取。

## 常见误区

1. 把 Q3D 当 HFSS 用：准静态提取不是 full-wave signoff。
2. 把 partial inductance 当 loop inductance：没有 return path 的 L 值容易误导。
3. 只看电感不看电阻：power module 和 busbar 的 AC loss 同样重要。
4. 导入全细节 CAD 不简化：求解慢，而且未必更准。
5. terminal 定义随意：source/sink 位置错误会直接改变结果。
6. 不做量级检查：仿真结果必须和手算/经验/测量对上。
7. 不做频率 sweep：只看 DC 或单频点容易漏掉 skin/proximity effect。
8. 导出模型后不验证：SPICE 子电路也要做阻抗/瞬态 sanity check。
9. 忽略接触电阻：大电流连接、氧化层、压接/螺栓接触面可能成为关键。
10. 把 Q3D 结果独立看：寄生参数最终要进入电路、热、结构或系统仿真才有意义。

## 推荐工作流

### 电力电子 busbar / power module

1. 明确开关回路、DC-link 回路、gate loop 和 sense loop。
2. 保留真实电流路径、端子、叠层、绝缘层和关键接触面。
3. 在 Q3D 提取 R/L/C，重点看 loop inductance、mutual inductance 和 AC resistance。
4. 把模型导入 Twin Builder/SPICE，加入器件模型和驱动模型，观察 overshoot、ringing、current sharing。
5. 把电流损耗映射到 Icepak/Mechanical 做热和应力分析。
6. 用 double pulse test 或阻抗测量校准模型。

### 高速封装 / connector / BGA transition

1. 先确定频段和是否满足准静态假设。
2. 只截取关键 transition，不要盲目跑整板。
3. 明确 signal/return terminals。
4. 提取 RLCG 或 IBIS package model。
5. 在电路/通道仿真中看 delay、ringing、ground bounce、crosstalk。
6. 如果频率高到传播/谐振显著，转 HFSS/Clarity 做 full-wave 校验。

### PCB 局部 PDN / via array

1. 截取 BGA power/ground via 区域。
2. 定义 power rail 和 ground return。
3. 提取局部 R/L/C，分析 via starvation 和 spreading inductance。
4. 把结果合入更大 PDN 模型。
5. 与 SIwave/PIPro/Sigrity 的整板 PDN 结果交叉验证。

## 横纵交汇洞察

### 洞察一：Q3D 的核心不是「场」，而是「模型」

HFSS、CST、Feko 这类工具经常以场分布和全波响应为中心；Q3D 的交付物更像工程模型。它真正有价值的地方，是把三维几何变成电路模型，让后续系统仿真能回答「会不会振铃」「会不会过压」「会不会 ground bounce」「会不会串扰」。

### 洞察二：Q3D 很适合设计迭代，但不适合替代签核

Q3D 速度和模型输出适合做结构迭代：母排间距改一点、bond wire 多一根、via 数量变一下、terminal 位置换一下，寄生参数怎么变。

但如果问题已经进入高频辐射、完整通道、眼图、EMI 合规、封装 cavity resonance，Q3D 不是终点。它应该和 HFSS/SIwave 或其他 full-wave/SI/PI 平台配合。

### 洞察三：竞品选择往往不是「谁更准」，而是「你处在哪个设计生态」

如果团队在 Allegro/APD 里做封装和 PCB，Cadence Sigrity/Clarity 的工作流优势很强。

如果团队在 ADS 里做 SerDes、channel 和测试测量关联，Keysight SIPro/PIPro 很顺。

如果团队需要 PCB 设计师级别的自动化验证，HyperLynx 更友好。

如果团队在 Ansys 做电磁、热、结构、电力电子和系统仿真，Q3D 的生态价值就很高。

所以工具选择不只是 solver accuracy，还包括 CAD 数据、模型交付、自动化、团队习惯、许可证、HPC、测量闭环和下游仿真平台。

## 结论

Ansys Q3D Extractor 是一款很有边界感的工具。它不该被理解成 HFSS 的低配版，也不该被理解成 SIwave 的替代品。它的核心能力是：对电子互连结构做 2D/3D 准静态寄生参数提取，并把 RLCG 转成电路和系统仿真可用的模型。

它最适合的场景，是那些「几何不简单、手算不可靠、全波又太重、结果还必须进电路仿真」的问题。

如果你做高速封装、BGA 过渡、连接器、bond wire、busbar、SiC/IGBT 功率模块、局部 PCB 电源回路，Q3D 是很值得掌握的工具。

但用好它的前提，是你必须知道自己要提取什么。Q3D 不会自动替你定义电路回路，也不会替你判断准静态假设是否成立。terminal、return path、频率范围、几何简化和模型验证，才是 Q3D 工作流里真正决定结果质量的地方。

## 信息来源

- Ansys, Q3D Extractor product page: https://www.ansys.com/products/electronics/ansys-q3d-extractor
- Ansys, HFSS product page: https://www.ansys.com/products/electronics/ansys-hfss
- Ansys, SIwave product page: https://www.ansys.com/products/electronics/ansys-siwave
- Ansys, Maxwell product page: https://www.ansys.com/products/electronics/ansys-maxwell
- Cadence, Clarity 3D Solver: https://www.cadence.com/en_US/home/tools/system-analysis/em-solver/clarity.html
- Cadence, Sigrity X Platform: https://www.cadence.com/en_US/home/tools/sigrity-x.html
- Cadence, Clarity PCB Extraction: https://www.cadence.com/en_US/home/tools/ic-package-design-and-analysis/si-pi-analysis/clarity-extraction/pcb-extraction.html
- Siemens, HyperLynx Advanced Solvers: https://www.siemens.com/en-us/products/pcb/hyperlynx/advanced-solvers/
- Keysight, PathWave SIPro: https://www.keysight.com/sg/en/product/W3033E/pathwave-sipro.html
- Keysight, PathWave PIPro: https://www.keysight.com/zz/en/product/W3034E/pathwave-pipro.html
- Keysight, ADS Core with SIPro/PIPro: https://www.keysight.com/zz/en/product/W3625B/pathwave-ads-core-em-design-layout-hsd-ckt-sim-sipro-pipro.html
- Keysight, EM Design / EMPro: https://www.keysight.com/us/en/products/software/pathwave-design-software/pathwave-em-design-software.html
- COMSOL, AC/DC Module: https://www.comsol.com/acdc-module
- Dassault Systemes, CST Studio Suite: https://chinanetcenter.3ds.com/products/simulia/cst-studio-suite
- Altair, Feko: https://altair.com/feko/

## 中英术语对照表

| 中文术语 | 英文术语 / 缩写 | 说明 |
|---|---|---|
| 寄生参数 | Parasitic Parameters | 非理想导体、介质和结构引入的 R/L/C/G 等参数 |
| 寄生提取 | Parasitic Extraction | 从几何结构中计算并提取寄生参数的过程 |
| 电阻 | Resistance, R | 导体阻碍电流流动的参数 |
| 电感 | Inductance, L | 电流变化时储存磁场能量并产生感应电压的参数 |
| 电容 | Capacitance, C | 导体之间储存电场能量的参数 |
| 电导 | Conductance, G | 介质泄漏或损耗路径的导电能力 |
| RLCG 矩阵 | RLCG Matrix | 多导体互连结构的电阻、电感、电容、电导矩阵 |
| 准静态 | Quasi-static | 结构尺寸相对波长较小时，可近似忽略完整波传播效应的电磁分析方法 |
| 全波电磁仿真 | Full-wave EM Simulation | 直接求解完整 Maxwell 方程并考虑传播、辐射、谐振等效应的仿真 |
| 矩量法 | Method of Moments, MoM | 常用于电磁积分方程求解的数值方法 |
| 快速多极子法 | Fast Multipole Method, FMM | 加速大规模 MoM 求解的算法 |
| 有限元法 | Finite Element Method, FEM | 将求解区域离散成有限单元的数值方法 |
| 趋肤效应 | Skin Effect | 高频电流集中在导体表面的现象 |
| 邻近效应 | Proximity Effect | 相邻导体磁场影响电流分布的现象 |
| 欧姆损耗 | Ohmic Loss | 电阻导致的能量损耗 |
| 介质损耗 | Dielectric Loss | 介质极化和泄漏导致的能量损耗 |
| 部分电感 | Partial Inductance | 未闭合回路中导体片段的电感表征，需谨慎解释 |
| 回路电感 | Loop Inductance | 完整电流回路对应的电感，更接近实际电路行为 |
| 互感 | Mutual Inductance | 两个电流回路或导体之间的磁耦合 |
| 自感 | Self Inductance | 单个回路自身的电感 |
| 端子 | Terminal | 仿真中定义电流/电压输入输出的位置 |
| 激励源 | Source / Excitation | 仿真中施加电压、电流或端口激励的位置 |
| 回流路径 | Return Path | 电流闭合的返回路径，常由地、负母排或参考导体提供 |
| 等效电路 | Equivalent Circuit | 用电阻、电感、电容等元件表示电磁结构行为的电路模型 |
| SPICE 子电路 | SPICE Subcircuit | 可在 SPICE 类电路仿真器中调用的子模型 |
| IBIS 封装模型 | IBIS Package Model | IBIS 标准中描述封装寄生的模型 |
| HSPICE W 元件 | HSPICE W-Element | HSPICE 中用于多导体传输线建模的元件 |
| AEDT | Ansys Electronics Desktop | Ansys 电子电磁仿真平台 |
| Twin Builder | Ansys Twin Builder | Ansys 系统级多域仿真平台，原 Simplorer 相关能力被整合其中 |
| HFSS | High Frequency Structure Simulator | Ansys 的 3D 全波高频电磁仿真工具 |
| SIwave | Ansys SIwave | Ansys 面向 PCB/封装 SI/PI/EMI 的专用工具 |
| Maxwell | Ansys Maxwell | Ansys 低频电磁和机电设备仿真工具 |
| 信号完整性 | Signal Integrity, SI | 关注高速信号波形、反射、串扰、损耗、抖动和误码 |
| 电源完整性 | Power Integrity, PI | 关注电源阻抗、压降、噪声、瞬态响应和 PDN |
| 电磁干扰/兼容 | EMI/EMC | 电磁干扰与电磁兼容 |
| 电源分配网络 | Power Distribution Network, PDN | 从电源到负载的完整供电网络 |
| 串扰 | Crosstalk | 相邻导体或通道之间的电磁耦合干扰 |
| 地弹 | Ground Bounce | 地网络寄生电感导致参考地电位瞬态跳变 |
| 振铃 | Ringing | 寄生 L/C 造成的瞬态振荡 |
| 过压尖峰 | Voltage Overshoot / Spike | 开关瞬间因寄生电感等产生的电压尖峰 |
| 母排 | Busbar | 大电流配电中常用的金属导体结构 |
| 直流母线电容 | DC-link Capacitor | 电力电子 DC bus 上用于储能和滤波的电容 |
| 绝缘栅双极晶体管 | Insulated Gate Bipolar Transistor, IGBT | 常见功率开关器件 |
| 碳化硅器件 | Silicon Carbide Device, SiC Device | 高压高速功率器件 |
| 双脉冲测试 | Double Pulse Test, DPT | 用于评估功率器件开关行为和寄生影响的测试方法 |
| 键合线 | Bond Wire | 芯片和封装引脚之间的金属线连接 |
| 引线框架 | Lead Frame | 封装中承载芯片并连接外部引脚的金属结构 |
| 球栅阵列封装 | Ball Grid Array, BGA | 以焊球阵列作为外部连接的封装形式 |
| 重新布线层 | Redistribution Layer, RDL | 封装内用于重新分配芯片 I/O 的金属布线层 |
| 硅通孔 | Through-Silicon Via, TSV | 穿过硅衬底的垂直互连结构 |
| S 参数 | Scattering Parameters, S-parameters | 高频网络反射和传输特性的参数表达 |
| 插入损耗 | Insertion Loss | 信号通过通道后的幅度损耗 |
| 回波损耗 | Return Loss | 阻抗不连续导致反射的指标 |
| 设计签核 | Signoff | 产品进入制造前的最终仿真/验证确认 |
| 自适应网格 | Adaptive Meshing | 根据误差自动细化网格以提升精度的方法 |
| 高性能计算 | High-Performance Computing, HPC | 多核、多节点或云资源加速求解 |
| 参数化扫描 | Parametric Sweep | 对几何或材料参数做多组仿真比较 |
| 优化 | Optimization | 自动寻找满足目标函数的设计参数 |
| 接触电阻 | Contact Resistance | 接触面、氧化层、压接或焊接区域引入的电阻 |
| 电热分析 | Electrothermal Analysis | 同时考虑电流损耗和温升的分析 |
| 热应力 | Thermal Stress | 温度变化引起的机械应力 |
