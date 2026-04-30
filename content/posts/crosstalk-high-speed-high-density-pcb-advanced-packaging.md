

+++
title = "线短了，问题没少：高速高密电路与先进封装中的串扰问题"
date = 2026-04-30T20:00:00+08:00
draft = false
slug = "crosstalk-high-speed-high-density-pcb-advanced-packaging"
description = "高速高密电路中的串扰问题分析，重点覆盖 BGA、RDL、硅中介层、TSV 与先进封装。"
tags = ["PCB", "Signal Integrity", "SI", "Crosstalk", "BGA", "TSV", "先进封装"]
categories = ["硬件设计"]
columns = ["高速电路专栏"]

+++



# 当下高速高密电路中的串扰问题

> 研究时间：2026-04-30 | 关注对象：高速高密电路、先进封装、BGA、RDL、微凸点、TSV、2.5D/3D 封装 | 方法：横纵分析法

## 一句话判断

高速高密电路里的串扰，已经不再只是「两根线靠太近」的问题，而是信号、返回路径、电源地网络、封装结构、垂直互连和制造可靠性共同形成的系统级耦合问题。先进封装把走线变短了，也把互连密度、垂直电磁耦合、返回路径不连续、焊球/微凸点失效敏感性推到了前台。

我的判断是：BGA 阶段的核心矛盾是封装到 PCB 过渡区的返回路径和 via field 串扰；2.5D/3D 阶段的核心矛盾变成了微米级间距下的 RDL/微凸点/TSV 阵列耦合，以及 chiplet 间高并行低摆幅接口对噪声裕量的压缩。

## 纵向分析：串扰问题为什么一路变严重

早期高速板级设计里，串扰主要发生在长距离平行走线之间。问题相对直观：相邻线之间有互电容和互电感，侵扰线的边沿越快、两线越近、平行长度越长，受害线上的近端串扰和远端串扰越明显。那时的常规解法也直观，拉大间距、加地线、控制参考平面、避免长距离同层并行。

BGA 把问题推进了一层。

BGA 的价值是高 I/O 密度和较短的封装引出，但它把大量信号、地、电源球压缩到二维阵列里。高速 SerDes 从芯片焊盘穿过封装球、PCB via、背钻/过孔 stub、逃逸布线时，信号的返回电流未必能沿着理想路径闭合。返回路径一旦绕远，环路电感上升，侵扰信号就更容易把能量注入邻近 ball/via/channel。2015 年关于大于 25 Gb/s SerDes 的 BGA pin-out 研究已经把「封装 pin-out 与 PCB via crosstalk」视为限制高速串行链路性能的重要来源，尤其会引入 jitter。

再往后，2.5D 硅中介层和 HBM 把互连长度缩短，但代价是线距、via 间距、凸点间距进入更激进的尺度。传统 PCB 上可以靠几倍线宽间距解决的问题，在硅中介层、RDL、微凸点阵列里变成面积成本问题。Micromachines 2023 年的高频封装互连串扰研究在 26 GHz、1-7 微米布线间距下讨论串扰抑制，正说明先进封装里的串扰已经进入「靠拉开距离很贵」的阶段。

TSV 又把问题从二维推进到三维。

TSV 的优势是短路径、高带宽、低延迟和高密度。问题是 TSV 是穿过硅衬底的垂直金属柱，周围有介质 liner、硅衬底、邻近 TSV 和电源地网络。它既有 TSV-to-TSV 耦合，也有 TSV-to-substrate 噪声耦合。到了 3D IC 里，成千上万个 TSV 放在有限面积内，电磁干扰和串扰不再是边角问题，而是信号完整性、电源完整性、热和可靠性共同作用的结果。

UCIe 这种 chiplet 互连标准则代表了当前趋势。UCIe 官方说明把它定义为封装级 die-to-die 互连标准，并在 2.0 中加入 3D packaging 支持，UCIe-3D 面向 hybrid bonding，覆盖从 10-25 微米到 1 微米甚至更小的 bump pitch 范围。这个尺度变化很关键：当互连 pitch 继续缩小，接口可以更宽、更低功耗，但单位面积里的耦合路径也更多，噪声预算反而更紧。

所以串扰问题的演进可以概括成四个阶段：

| 阶段 | 主要场景 | 串扰主因 | 工程重心 |
|---|---|---|---|
| PCB 高速线 | 长距离平行线、连接器 | 互容、互感、返回路径 | 间距、参考平面、拓扑 |
| BGA + PCB via field | BGA 逃逸、SerDes、厚板过孔 | ball/via 排布、GND 缺失、stub、返回路径中断 | pin-out、GSG/差分布局、via 屏蔽、背钻 |
| 2.5D/RDL/硅中介层 | HBM、chiplet、RDL channel | 微米级线距、broadside/edge coupling、via transition | 3D EM、线宽线距、屏蔽、编码、低摆幅接口 |
| 3D IC/TSV/hybrid bonding | 堆叠 die、TSV 阵列、UCIe-3D | TSV-to-TSV、TSV-to-substrate、电源噪声、热-机械可靠性 | TSV 阵列、地 TSV、liner、keep-out、SI/PI/thermal co-design |

## 横向分析：几类热门先进封装里的串扰差异

### 1. BGA：真正危险的地方常在封装到板的过渡区

BGA 的串扰不是单纯发生在焊球之间。更常见、更麻烦的是 BGA ball、package substrate、PCB via field、参考平面开窗和逃逸走线叠在一起后形成的耦合。

典型风险有四类。

第一，pin-out 把高速信号放得太近，或者把侵扰信号和受害信号安排在相邻球位，却没有足够的地球/返回路径隔离。

第二，BGA 下方的过孔阵列太密，厚板 through via 较长，via barrel 和 stub 会在高速频段形成强耦合。对 25 Gb/s 以上 SerDes，via crosstalk 已经足以造成 jitter 和眼图闭合。

第三，GND solder ball 失效或缺失会显著恶化串扰。2024 年 IEEE Transactions on Electromagnetic Compatibility 的 BGA GSG 结构研究专门评估了 ground solder ball failure 对微波电路串扰的影响，核心结论是 GSG 中的地球不只是直流连接，而是高频返回路径和屏蔽结构的一部分。

第四，BGA 封装和 PCB 的协同设计不够。只看 package ball map 或只看 PCB escape，都可能低估真实串扰，因为最坏点常在二者拼接处。

BGA 的治理优先级应该是：

1. 高速差分对优先保证连续返回路径，而不是只追求线长相等。
2. 高速信号球之间用 GND ball 或 GND via fence 隔离，关键通道采用 GSG/SGS 思路。
3. BGA escape 的 via field 必须做 3D EM 提取，不能只靠 2D 传输线规则。
4. 对 25/56/112 Gb/s PAM4 级别链路，把封装 pin-out、PCB via、connector 一起纳入 channel 仿真。
5. 制造可靠性要进入 SI 评估：地焊球开路、void、偏移不应只归类为装配问题。

### 2. RDL、Fan-out、微凸点：线变短了，但单位面积耦合更密

Fan-out、RDL 和微凸点互连的优势是薄、短、高密。它们适合 chiplet、AI 加速器、移动 SoC、射频/高速混合集成。问题在于，RDL 间距和微凸点 pitch 缩小后，串扰的主要约束从「长线」转向「密集短互连」。

短互连不代表串扰可以忽略。高速数字边沿的频谱很宽，微米级间距下的互容、互感和返回路径不连续仍然会在邻近通道上产生明显扰动。尤其在低摆幅并行接口中，单次耦合幅度可能不大，但受害信号的噪声裕量本来就小，结果仍然可能表现为 jitter、eye height 下降、错误采样或训练余量降低。

Micromachines 2023 的高频封装互连研究给了一个很有意思的方向：不只从几何上抑制串扰，也可以从编码/信令层降低串扰敏感性。该研究在 26 GHz、1-7 微米间距下，用 delay-insensitive code 对比同步传输，1-of-2 和 1-of-4 编码平均降低串扰峰值约 22.9% 和 17.5%。这不是说所有封装都应该改编码，而是说明先进封装时代的串扰治理已经从单纯 layout 问题，扩展到电路、协议、编码和封装的协同优化。

### 3. 硅中介层和 HBM：远端串扰与功耗一起被优化

HBM/硅中介层是当前最典型的高密封装场景。多个 HBM stack 与逻辑 die 通过硅中介层连接，通道数量巨大，间距紧，功耗敏感。

硅中介层的好处是工艺精细、可实现高密度 wiring；坏处是当大量线在薄介质层中并行，far-end crosstalk、阻抗不连续和 via transition 会成为限制。2022 年关于 next-generation HBM 的 interposer channel 研究提出 vertical tabbed vias，用几何结构降低自电容和远端串扰。论文报告相对传统 worst case strip line，8 Gbps 下 eye-width、eye-height、eye-jitter 分别改善 17.6%、29% 和 9.56%，动态功耗降低约 28%。

这个案例说明一件事：在先进封装里，串扰优化和功耗优化经常是同一个问题的两面。减小不必要电容，不仅降低耦合，也降低动态功耗；但如果过度压缩间距，功耗和面积收益又可能被 SI margin 吃掉。

### 4. TSV：三维串扰最难，因为它同时碰到衬底和阵列

TSV 的串扰可以分成三层。

第一层是 TSV-to-TSV。相邻 TSV 之间通过互容、互感耦合，pitch 越小、平行长度越长、返回路径越差，噪声越明显。

第二层是 TSV-to-substrate。TSV 穿过硅衬底，衬底不是理想绝缘体，高频噪声可以通过衬底传播。TSV liner 的介电常数、厚度、损耗、硅电阻率都会影响耦合。

第三层是电源地噪声和热/机械可靠性。TSV-based 3D IC 里电流密度和工作频率提高，P/G TSV 上的电源噪声会上升；同时 TSV 铜填充、liner、热膨胀失配、void/seam 等制造问题会改变实际互连阻抗和可靠性。

TSV 的治理手段也分成几类。

结构上，增加 TSV pitch、优化信号/地 TSV 位置、使用差分 TSV、采用 GND TSV shield 或 coaxial/annular shield。2022 年 octagonal TSV array 研究显示，交错布局、差分信号和八边形阵列有助于降低串扰；其提出的八边形布局相对传统阵列串扰噪声降低接近 44%，并进一步用分裂 TSV 结构减少占用面积。

材料上，优化 TSV liner 材料、厚度和硅衬底电阻率。2020 年关于 TSV dielectric materials 的研究显示，仅改变 liner 材料也能降低噪声耦合，文中给出最高约 30% 的改善。

方法上，必须做全 3D 电磁提取。KAIST 的 TSV/interposer SI 研究强调用 3D EM simulation 验证 TSV model，并同时分析 insertion loss 和 TSV-to-TSV noise transfer function。这对工程项目很关键：TSV 不能只当作 lumped via，也不能只在版图 DRC 层面判断。

## 横纵交汇洞察

### 洞察一：先进封装没有消灭串扰，只是改变了串扰的位置

很多人对先进封装有一个误解，以为互连变短，串扰就自然变小。真实情况更接近这样：长距离传输损耗下降了，但局部密度、垂直过渡、返回路径、低摆幅接口带来的串扰敏感性上升了。

BGA 时代最容易出问题的是 package-to-board transition。2.5D 时代最容易出问题的是 RDL/中介层密集通道。3D 时代最容易出问题的是 TSV 阵列、衬底耦合和电源地噪声。

所以设计评审时不能只问「线距够不够」。更应该问：

- 侵扰信号的返回电流在哪里闭合？
- 受害信号的参考平面有没有被切断？
- 地球、地 TSV、地 bump 是真实高频屏蔽，还是只是 DC ground？
- BGA via field、RDL channel、TSV array 有没有一起做 3D EM？
- 最坏串扰是否在封装/板级/芯片边界的拼接处？

### 洞察二：串扰治理从 layout 规则变成 system co-design

过去的串扰规则经常写成「3W 间距」「差分对旁边别并行太长」。这些规则在 PCB 上仍然有用，但在先进封装里不够。

现在需要至少五层协同：

| 层级 | 典型动作 |
|---|---|
| 几何 | 间距、线宽、层叠、via pitch、TSV pitch、keep-out |
| 返回路径 | GND ball、GND TSV、via fence、参考平面连续性 |
| 材料 | low-k/high-resistivity substrate、TSV liner、封装介质损耗 |
| 电路/信令 | 差分、低摆幅、编码、均衡、时钟/数据训练 |
| 系统验证 | S 参数、TDR/TDT、眼图、jitter、SSN、thermal/reliability corner |

### 洞察三：地结构的价值被低估

BGA 里的 ground solder ball、RDL 里的 shield trace、TSV 阵列里的 ground TSV，本质上都是给高频返回电流安排更短、更稳定的路。它们看起来像「浪费面积」，但在高速高密系统里往往是买 margin。

真正难的是 trade-off：地结构越多，串扰越低，但 I/O 密度、走线资源和成本受影响。先进封装的工程重点不是一味加地，而是在最敏感的通道、最差的 transition、最容易同频翻转的 bus 上精确加地。

## 工程建议清单

### BGA / PCB 协同设计

- 高速 SerDes ball map 在封装定义阶段就要和 PCB escape 一起仿真。
- 差分对不要只看 intra-pair skew，也要看 pair-to-pair coupling。
- 高速信号周围优先布 GND ball/GND via，关键位置使用 GSG。
- BGA 下方 through via 尽量缩短 stub，必要时背钻或改 blind/buried via。
- 把 ground solder ball failure、void、偏移纳入 worst-case SI 检查。

### RDL / Fan-out / 中介层

- 微米级 RDL 间距下，不能用 PCB 经验规则直接外推。
- 对 broadside coupling 和 far-end crosstalk 分别建模。
- 对 HBM/chiplet 宽并行接口，重点看同组信号同步翻转时的 worst-case pattern。
- 低功耗设计不要只看 Cload，也要看耦合电容导致的动态噪声。
- 关键 channel 应做 3D EM + 电路联合仿真，而不是只用静态 RC extraction。

### TSV / 3D IC

- TSV 阵列布局要把 signal/ground 分布作为 SI 变量，不只是布线资源变量。
- 对高敏感信号优先考虑 differential TSV 或 ground TSV shield。
- TSV pitch、diameter、liner、硅电阻率、keep-out zone 需要联合扫参。
- TSV-to-substrate coupling 要和电源地噪声一起看。
- TSV 制造缺陷、Cu protrusion、void/seam、热循环后的阻抗变化，应该进入可靠性与 SI 联合评估。

### 验证方法

- 频域：S 参数、NEXT/FEXT、mode conversion、noise transfer function。
- 时域：TDR/TDT、eye height、eye width、eye jitter、victim waveform overshoot/undershoot。
- 场景：single aggressor、multiple aggressor、same-direction switching、opposite-direction switching、power noise corner。
- 层级：die/package/board 分别看，再做 stitched channel；最坏点通常在边界拼接处。

## 结论

当下高速高密电路中的串扰问题，最核心的变化是「局部密度」超过了「互连长度」成为主要矛盾。BGA、微凸点、RDL、硅中介层、TSV 都在把系统往更短、更密、更宽、更低功耗的方向推，但每一步都会压缩电磁隔离空间。

如果只给一个设计原则，我会给这个：

不要把串扰当成布线后期的 cleanup 项，而要把它当成封装架构的一等约束。

BGA 的 pin-out、HBM 的 interposer channel、TSV 的 signal/ground array、UCIe 的 bump pitch 和 package option，都应该在架构阶段就用 SI/PI/thermal/reliability 的联合视角评估。否则后期再靠加地、换层、调线距，只是在一个已经被架构锁死的空间里补救。

## 信息来源

- UCIe Consortium, Specifications, UCIe package-level die-to-die interconnect and UCIe 2.0 3D packaging notes: https://www.uciexpress.org/specifications
- UCIe Consortium, Packaging Technologies Webinar Q&A, standard/advanced package bump pitch and HBM coexistence discussion: https://www.uciexpress.org/post/ucie-packaging-technologies-webinar-q-a-recap
- Bo Sun, Zhaoxin Xu, "Crosstalk Analysis of Delay-Insensitive Code in High-Speed Package Interconnects", Micromachines, 2023: https://www.mdpi.com/2072-666X/14/5/1033
- "A Novel Interposer Channel Structure with Vertical Tabbed Vias to Reduce Far-End Crosstalk for Next-Generation High-Bandwidth Memory", Micromachines, 2022: https://www.mdpi.com/2072-666X/13/7/1070
- Wei Yao et al., "Design of package BGA pin-out for >25Gb/s high speed SerDes considering PCB via crosstalk", DOI: 10.1109/EMCSI.2015.7107669: https://www.researchgate.net/publication/283592423_Design_of_package_BGA_pin-out_for_25Gbs_high_speed_SerDes_considering_PCB_via_crosstalk
- Kaixuan Song et al., "Impact of BGA Package Failure on Crosstalk in Microwave Circuits Using GSG Structure", IEEE Transactions on Electromagnetic Compatibility, 2024: https://www.researchgate.net/publication/379103179_Impact_of_BGA_Package_Failure_on_Crosstalk_in_Microwave_Circuits_Using_GSG_Structure
- Jonghyun Cho, Joungho Kim, "Signal integrity design of TSV and interposer in 3D-IC", KAIST / IEEE LASCAS 2013: https://pure.kaist.ac.kr/en/publications/signal-integrity-design-of-tsv-and-interposer-in-3d-ic
- Ziyu Liu et al., "Crosstalk Noise of Octagonal TSV Array Arrangement Based on Different Input Signal", Processes, 2022: https://www.mdpi.com/2227-9717/10/2/260
- "A Short Review of Through-Silicon via (TSV) Interconnects: Metrology and Analysis", Applied Sciences, 2023: https://www.mdpi.com/2076-3417/13/14/8301/html
- Wen-Wei Shen, Kuan-Neng Chen, "Three-Dimensional Integrated Circuit (3D IC) Key Technology: Through-Silicon Via (TSV)", Nanoscale Research Letters, 2017: https://pmc.ncbi.nlm.nih.gov/articles/PMC5247381/
