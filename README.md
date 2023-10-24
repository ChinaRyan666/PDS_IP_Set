# 紫光同创 PDS 软件使用——常用 IP 核的理解与配置
# 0 致读者


此篇为专栏[《紫光同创FPGA开发笔记》](https://blog.csdn.net/ryansweet716/category_12470860.html?spm=1001.2014.3001.5482)的第三篇，记录我的学习 **FPGA** 的一些开发过程和心得感悟，刚接触 **FPGA** 的朋友们可以先去此博客 [《FPGA零基础入门学习路线》](http://t.csdnimg.cn/T0Qw2)来做最基础的扫盲。

本篇内容基于笔者实际开发过程和正点原子资料撰写，将会详细讲解此次 **FPGA** 实验 **（IP 核配置）** 的全流程，**诚挚**地欢迎各位读者在评论区或者私信我交流！

本篇内容基于**紫光同创 Pango Design Suite** 软件（以下简称 **PDS**），我将会用四个基础的 **FPGA** 实验来讲解四个常用 **IP** 核的配置，分别是 **`PLL`**、单端口 **`RAM`**、双端口 **`RAM`**、**`FIFO`** 这四种 **IP** 核。

关于其他 **IP** 核的配置可翻阅我本专栏下的其他博客，关于 **IP** 核的具体讲解可阅读另一个专栏 [《Ryan的FPGA学习笔记》](https://blog.csdn.net/ryansweet716/category_12263937.html?spm=1001.2014.3001.5482) 的前四篇（超级详细）。

本文的工程文件**开源地址**如下（基于**ATK-DFPGL22G**，大家 **clone** 到本地就可以直接跑仿真，如果要上板请根据自己的开发板更改约束即可）：

> [https://github.com/ChinaRyan666/PDS_IP_Set](https://github.com/ChinaRyan666/PDS_IP_Set)

<br/>
<br/>


# 1 `PLL` IP 核


## 1.1 实验任务

本小节的实验任务是使用开发板的 **PLL IP** 输出 **5** 个不同时钟频率或相位的时钟。

<br/>

## 1.2 PLL IP 核简介

**`PLL`** 的英文全称是 **Phase Locked Loop**，即**锁相环**。**锁相环**作为一种**反馈控制电路**，其特点是利用外部输入的参考信号控制环路内部震荡信号的频率和相位。 因为锁相环可以实现输出信号频率对输入信号频率的自动跟踪，所以锁相环通常用于闭环跟踪电路。锁相环在工作的过程中，当输出信号的频率与输入信号的频率相等时，输出电压与输入电压保持固定的相位差值，即输出电压与输入电压的相位被锁住，这就是锁相环名称的由来。

**Logos PLL** 主要由**鉴频鉴相器**（PFD，Phase Frequency Detector）、**环路滤波器**（LF，Loop Filter）和**压控振荡器**（VCO，Voltage Controlled Oscillator）等组成。通过不同的参数配置，可实现信号的**调频、调相、同步、频率综合**等功能。

**Logos PLL** 的电路框图如下图所示：

![在这里插入图片描述](https://img-blog.csdnimg.cn/8271d112415346f888c003fe5f69a363.png#pic_center)

<center>Logos PLL 电路框图</center>
<br/>
<br/>




紫光同创 **Logos** 系列产品的 **PLL** 主要特性如下：


1. 频率综合，相位调整；
2. 可选的输入时钟动态选择；
3. 支持外部反馈和内部反馈两种反馈模式；
4. 支持 **PLL** 的动态配置；
5. 可选的输出时钟 **gate** 功能；
6. 可选的可编程的 **phase shift**；


**PLL** 的参考时钟**输入源**包括：时钟输入管脚输入的时钟、**PLL** 的参考时钟输入管脚输入的时钟，全局时钟，区域时钟或 **I/O** 时钟以及来自内部逻辑的信号。其中 **PLL** 的参考时钟输入管脚可以让 **PLL** 获得最好的性能，强烈推荐用户使用。而来自内部逻辑的信号则容易受到内部其它信号的干扰，建议用户谨慎使用。

![在这里插入图片描述](https://img-blog.csdnimg.cn/e1905addf5834ba3bb7b7fc8f515049e.png#pic_center)

<center>PLL 参考时钟选择示意图</center>
<br/>
<br/>


**PLL** 的反馈时钟输入源可以分为 **PLL** 内部反馈和 **PLL** 外部反馈两种，其中 **PLL** 内部反馈时钟源是由专用的内部时钟构成。 **PLL** 的外部反馈时钟源包括：时钟输入管脚输入的时钟、 **PLL** 反馈时钟管脚输入、全局时钟，区域时钟或，**I/O** 时钟以及来自内部逻辑的信号。其中来自内部逻辑信号则容易受到内部其它信号的干扰，建议用户使用 **PLL** 专用反馈时钟。


![在这里插入图片描述](https://img-blog.csdnimg.cn/0ef97cdf39834d4598fe6a79eb14b527.png#pic_center)

<center>PLL 外部反馈时钟选择示意图</center>
<br/>
<br/>


在本实验中，读者可以简单地理解为：外部时钟连接到具有时钟能力的输入引脚 **CCIO（ClockCapable Input）**，进入 **PLL**，产生不同**频率**和不同**相位**的时钟信号，然后驱动全局时钟资源。但是要进行更深入的 **FPGA** 开发，就必须理解器件的**时钟资源架构**。有关 **Logos** 时钟资源的更详细信息，读者后期可以花一些时间和精力去学习一下 **Logos** 官方的手册文档。

<br/>


## 1.3 IP 核配置讲解

我们首先创建一个空的工程，工程名为 **“ip_pll”**。接下来添加 **PLL IP** 核。在 **PDS** 软件的上方的菜单栏中 **“Tools”** 栏中单击 **“IP Compiler”** 按钮后弹出的 **“IP Compiler”** 窗口如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/c49f3bc644b148f6af81a9ef7efdcb2c.png#pic_center)

<center>“IP Compiler” 按钮</center>
<br/>
<br/>






![在这里插入图片描述](https://img-blog.csdnimg.cn/1194b3fae1d345b1a4de9173170ff858.png#pic_center)

<center>“IP Compiler” 窗口</center>
<br/>
<br/>

本实验使用的 **IP** 核路径是 **Module→PLL→PLL**，如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/706ee1d5e83c408a96ef75981f688337.png#pic_center)
<center>PLL IP</center>
<br/>
<br/>




我们点击上图 **IP** 窗口下的 **“PLL (1.5)” IP 核**后，界面如下图所示。标签号为 **1** 处为指定例化此 **IP** 的路径，标签号为 **2** 处给新建的 **PLL IP** 核命名，本实验我们给新建的 **PLL IP** 命名为 **pll_clk**，点击标签 **3** 处的 **“Customize”** 按钮是进入 **PLL IP** 参数配置页面。接下来的 **IP** 框里面的内容是该 **IP** 的基础信息，例如名称、版本号与所属公司（**Pango**）。**Part** 框中的信息为工程所使用的芯片的详细信息，即选择器件类型，根据自己的开发板型号选择即可。


![在这里插入图片描述](https://img-blog.csdnimg.cn/353d4a9b5554432aabf7fbb939f71727.png#pic_center)


<center>“IP Compiler” 窗口</center>
<br/>
<br/>

点击上图中的 **“Customize”** 按钮进入 “**Customize IP**”窗口对 **PLL** 的参数进行配置，“**Customize IP**” 窗口界面如下图所示： 图中的 “**Add IP**” 弹窗点击 **“Yes”**。


![在这里插入图片描述](https://img-blog.csdnimg.cn/0caf0dad486246f696a20af681d96aad.png#pic_center)

<center>“Add IP” 弹窗</center>
<br/>
<br/>


![在这里插入图片描述](https://img-blog.csdnimg.cn/751bda9f99d743d082c6a69324f6dd27.png#pic_center)


<center>“Customize IP” 窗口</center>
<br/>
<br/>


在选项卡 **Mode Selection** 界面有两个选项，一个是 **“Basic Configurations”** 基础配置模式，一个是 **“Advanced Configurations”** 高级配置模式。
1. **Basic 模式**
**Basic** 配置模式下，用户无需关心 **PLL** 的内部参数配置，只需输入期望的频率值、相位值、占空比等， 软件平台自动计算，得到最佳的配置参数。如果没有特殊应用，建议使用 **Basic** 模式配置 **PLL**。
2. **Advanced 模式**
**Advanced** 模式下，**PLL** 的内部参数配置完全开放，用户需要根据应用需求自行计算相应配置参数，才能正确配置。**Advanced** 模式下各个参数计算的详情用户可以参考官方的 **IP** 核手册，点击上图中左上角框出来的图标即可。

>本节实验只是 **PLL IP** 的基础使用，即使用默认的基础配置模式即可。

然后点击进入 **“Basic Configurations”** 选项卡界面， **Basic** 模式界面主要包括输入配置（**Input Configurations**）、**5** 个输出时钟配置（**Clkout 0~4 Configurations**）与显示 **PLL** 内部设置参数（**Show Internal Settings of PLL**），**Basic Configurations** 选项卡界面如下图所示:


![在这里插入图片描述](https://img-blog.csdnimg.cn/ae8e21f1c2f34e818980fdeb9e50e7d0.png#pic_center)

<center>Basic Configurations 选项卡界面</center>
<br/>
<br/>



把输入配置 “**Input Configurations**” 选项的输入时钟频率 **“Input Clock clkin1 Frequency”** 修改为我们开发板上的晶振频率 **50MHz**， 勾选 **“Enable Port pll_rst”** 复位使能信号，时钟 **IP** 核默认是高电平有效复位的。输入配置框其他的设置保持默认即可， 时钟锁存信号（**pll_lock**）的作用是指示 **PLL** 输出的时钟信号是否稳定，当 **pll_lock** 拉高代表 **PLL** 输出时钟稳定，反之则表示输出不稳定或者错误。 如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/19f23d9daf2347f4b0e26fe6abb14871.png#pic_center)
<center>“Input Configurations” 选项卡的设置</center>
<br/>
<br/>


接下来输出时钟配置选项 **“Clkout 0~4 Configurations”** 选项卡，在 **“Clkout Configurations”** 选项卡中，勾选 **5** 个时钟，并且将其 **“Desired Frequency”** 分别设置为 100、 100、 50、 25、 25，注意，第 **2** 个 **100MHz** 时钟的相移 **“Desired Phase Shift”** 一栏要设置为 **180**，第 **5** 个时钟的占空比 **“Desired Duty Cycle”** 设置为 **75.0%**。其他设置保持默认即可，如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/39130debf15a4796b2900ae97b93beae.png#pic_center)

<center>“Input Configurations” 选项卡的设置</center>
<br/>
<br/>

勾选显示 **PLL** 内部设置参数（**Show Internal Settings of PLL**），“**Internal Setting of PLL**” 框里面展示了对整个 **PLL** 的最终配置参数，这些参数都是根据之前用户输入的时钟需求由 IPC(IP Compiler)来自动配置， **PDS** 已经对参数进行了最优的配置，如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/09d9656a31a54838918b893aa228afee.png#pic_center)

<center>PLL 内部设置参数展示界面</center>
<br/>
<br/>


至此本实验所需要的时钟已配置完成， 接下来点击 “**Customize IP**” 窗口左上角的 “**Generate**” 在弹出的 “**Question**” 对话框选择 “**OK**” 即可，如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/c0a4174b38e845d3bbe7d40795092787.png#pic_center)

<center>“Generate” 界面</center>
<br/>
<br/>









点击 **“OK”** 后打印如下左图信息，至此时钟 **ip** 核配置成功，并生成 **pll_clk_tmpl.v** 文件。例化 **PLL IP** 时可以使用下图中 **pll_clk_tmpl.v** 文件红框中的代码。


![在这里插入图片描述](https://img-blog.csdnimg.cn/3e32a9c4971b40ab9f02389730dd3886.png#pic_center)

<center>PLL IP 配置完成信息</center>
<br/>
<br/>


然后如下图所示，关闭 **“Customize IP”** 页面与 **“IP Compiler”** 页面。


![在这里插入图片描述](https://img-blog.csdnimg.cn/5afade33069f4ee5abf6b3207dc2b3fb.png#pic_center)
<center>关闭 PLL IP 配置界面</center>
<br/>
<br/>


之后我们就可以在 **“Sources”** 窗口的 **“Designs”** 一栏中出现了该 **IP** 核 **“pll_clk”** 如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/f25e4f174f8a4cb0a49b90942c91e2c1.png#pic_center)

<center>“pl_clk” IP 核</center>
<br/>
<br/>


至此，我们的 **IP** 核就配置成功了，接下来就根据自己的功能进行代码编写即可，本实验也给大家编写了代码供大家参考，全部工程都在文首的 [Github开源地址](https://github.com/ChinaRyan666/PDS_IP_Set)。












<br/>
<br/>


# 2 单端口 `RAM` IP核


## 2.1 实验任务

本小节实验任务是使用 **PDS** 的 **IP Compiler** 配置一个单口 **RAM IP** ，使之能进行读写操作。

<br/>



## 2.2 单端口 RAM IP核简介

**RAM** 的英文全称是 **Random Access Memory**，即随机存取存储器， 它可以随时把数据写入任一指定地址的存储单元，也可以随时从任一指定地址中读出数据， 其读写速度是由时钟频率决定的。**RAM** 主要用来存放程序及程序执行过程中产生的中间数据、 运算结果等。

**Memory IP** 分为 **“Distributed RAM”** 与 **“DRM”**。

***

**`DRM 介绍`**

**DRM（Dedicated RAM Module）** 即专用 **RAM** 模块，**DRM Based RAM / FIFO IP** 是基于 **DRM** 设计的 **IP**，通过对 **DRM** 的级联调用实现 **RAM / ROM / FIFO** 等 **IP** 设计。这里主要说明如何用深圳市紫光同创电子有限公司的 **Pango Design Suite** 套件中 **IP Compiler** 工具（后文简称 **IPC**）生成并配置此类 **IP**。**DRM Based RAM / FIFO IP** 的分类为：

* **DRM Based Dual Port RAM：** 基于 DRM 的双端口 RAM

* **DRM Based Simple Dual Port RAM：** 基于 DRM 的简单双端口 RAM

* **DRM Based Single Port RAM：** 基于 DRM 的单端口 RAM

* **DRM Based ROM：** 基于 DRM 的 ROM

* **DRM Based FIFO：** 基于 DRM 的 FIFO

**Logos** 系列 **FPGA** 的 **DRM** 有高达 **18K bits** 的存储单元并且容量可被独立配置为 **2** 个 **9K bits** 或者 **1** 个 **18K bits**。每个 **DRM** 都能支持 **DP**（True Dual Port，双口） **RAM** 模式，同时也以被配置为 **SP**（Single Port，单口） **RAM** 模式，**SDP**（Simple Dual Port，简单双口） **RAM** 模式，**ROM** 模式，以及可选丢包重发的同步\异步 **FIFO** 模式。

**DRM** 资源还支持输入寄存器（**IR**）、输出寄存器（**OR**）以及 **Core Latch**，这使得 **DRM** 级联使用时拥有更加出色的性能表现。**DRM** 的总数取决于 **Logos** 系列器件类型。**Logos** 系列 **FPGA DRM** 的原语是各种模式的基础，其原语有两种：**GTP_DRM9K** 和 **GTP_DRM18K**，其支持类型如下图所示：

![在这里插入图片描述](https://img-blog.csdnimg.cn/1ea57a6b590d4a78814ea324a16948a3.png)

**`Distributed RAM 介绍`**

**Distributed RAM IP** 是紫光同创基于 **FPGA** 片内资源设计的 **IP**，适用于全系列 **FPGA** 产品，用户可以通过公司 **PDS(Pango Design Suite)** 套件中的 **IPC(IP Compiler)** 工具完成 **IP** 模块的配置和生成。**Distributed RAM IP** 包含 5 个子 **IP**：

* **Distributed ROM：** 分布式 ROM

* **Distributed Single Port RAM：** 分布式单口 RAM

* **Distributed Simple Dual Port RAM：** 分布式简单双端口 RAM

* **Distributed Shift Register：** 分布式移位寄存器

* **Distributed FIFO：** 分布式 FIFO

**PDS** 软件自带的 **IP Compiler** 已经生成了各种存储器，例如 **RAM**、 移位寄存器、**ROM** 以及 **FIFO** 缓冲器。**RAM** 与 **ROM** 这两者的区别是 **RAM** 是一种随机存取存储器，不仅仅可以存储数据， 同时支持对存储的数据进行修改；而 **ROM** 是一种只读存储器，也就是说，在正常工作时只能读出数据，而不能写入数据。 需要注意的是，配置成 **RAM** 或者 **ROM** 使用的资源都是 **FPGA** 内部的 **Distributed RAM**，只不过配置成 **ROM** 时只用到了嵌入式 **Distributed RAM** 的读数据端口。

***

本小节我们主要介绍使用 **IPC(IP Compiler)** 工具生成的单口 **RAM** 实现读写的功能。

单端口 **RAM**（**DRM Based Single Port RAM**） 只有一个端口，读/写只能通过这一个端口来进行。单端口 **RAM** 只有一组数据总线、地址总线、时钟信号以及其他控制信号。有关 **DRM** 的更详细的介绍，请读者参阅 **Pango** 官方的手册文档。

**DRM Base Single Port RAM** 的单端口 **RAM** 的框图如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/60c63f50ae0e4c7f97f440c9f2df4da9.png#pic_center)

<center>单端口 RAM 框图</center>
<br/>
<br/>

各个端口的功能描述如下：

* **addr：** 写地址信号。

* **addr_strobe：** 写地址选锁存号，高电平对应地址无效，上一个地址被保持，低电平对应地址有效。

* **wr_data：** 写数据信号。

* **rd_data：** 读数据信号。

* **wr_en：** 写使能信号， 高电平表示向 RAM 中写入数据，低电平表示从 RAM 中读出数据。

* **clk：** RAM 的时钟信号。

* **clk_en：** 时钟使能信号，高电平对应地址有效，低电平对应地址无效。

* **rst：** 复位信号，高有效。

* **wr_byte_en：** Byte Write 使能信号，当配置 “Enable Byte Write” 选项勾选时有效，位宽范围 1~128。高电平对应 Byte 值有效，低电平对应 Byte 值无效。

* **rd_oce：** 输出寄存使能信号，高电平对应地址有效，读数据寄存输出，低电平对应地址无效，读数据保持。


<br/>


## 2.3 IP 核配置讲解

首先在 **PDS** 软件中创建一个名为 **ip_1port_ram** 的工程，工程创建完成后，在 **PDS** 软件的上方的菜单栏中 “**Tools**” 栏中单 “**IP Compiler**” 按钮后弹出的 “**IP Compiler**” 窗口如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/f2c96cb921e74a439a053dd7b807d612.png#pic_center)

<center>点击 “IP Compiler”</center>
<br/>
<br/>



![在这里插入图片描述](https://img-blog.csdnimg.cn/6f526b83f1f3448ebf1b76cbace852a9.png#pic_center)

<center>“IP Compiler” 窗口</center>
<br/>
<br/>


本小节实验使用的 **IP** 核路径是 **Module→Memory→DRM→DRM Base Single Port RAM IP** 核，如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/d27f7c013ac04f49a246f342cf911a4d.png#pic_center)

<center>DRM Based Single Port RAM</center>
<br/>
<br/>

点击上图中红框中的 **IP** 后如下图所示：


![在这里插入图片描述](https://img-blog.csdnimg.cn/c83f4dba353747bea299d677580bb181.png#pic_center)

<center>DRM Based Single Port RAM IP 详情页面</center>
<br/>
<br/>

>**Pathname：** 新建 IP 核在工程所在路径，这里保持默认即可。

>**Instance Name：** 在这里给新建的 RAM IP 命名，我们这里命名为 “ram_1port” 。


接下来的 **IP** 框里面的内容是该 **IP** 的基础信息，例如名称、版本号与所属公司（**Pango**）。**Part** 框中的信息为工程所使用的芯片的详细信息。

点击上图中的 “**Customize**” 按钮进入 “**Customize IP**” 窗口对 **RAM IP** 的参数进行配置，“**Customize IP**” 窗口界面如下图所示：图中的 “**Add IP**” 弹窗点击 “**Yes**” 后进入 “**Customize IP**” 界面进行单口 **RAM** 的参数配置，“**Customize IP**” 界面如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/f8e0c7f7ca564359abfb702ef0854ae9.png#pic_center)
<center>“Add IP” 弹窗</center>
<br/>
<br/>


![在这里插入图片描述](https://img-blog.csdnimg.cn/a3e2240ac6f44be89b5ff545b5e35e57.png#pic_center)

<center>Customize IP 界面</center>
<br/>
<br/>




**本实验我们主要进行如下配置：**



![在这里插入图片描述](https://img-blog.csdnimg.cn/1b8e9a72f37e468f8c73e3ed13c85d32.png#pic_center)


<center>“DRM Based Single Port RAM” 参数配置界面</center>
<br/>
<br/>


**Customize IP** 界面主要包括如下选项：



>**DRM Resource Usage：** 选项主要说明 DRM 资源使用情况。该选项下的 “DRM Resource Type” 是 DRM 资源类型，可以设置 “AUTO”、“DRM9K”、“DRM18K” 三种模式。三种模式可以根据你需要地址宽度与数据宽度来来设置，一般我们设置为 “AUTO” 模式。
> <br/>
>![在这里插入图片描述](https://img-blog.csdnimg.cn/66ffe48686e84b1ba21a3842e56fea52.png#pic_center)
><center>9Kb DRM 模式 Single Port RAM 模式和 ROM 模式列表</center>
><br/>
>
>![在这里插入图片描述](https://img-blog.csdnimg.cn/7ae1911ef7e348b4b6c7733baa3dbdef.png#pic_center)
><center>18Kb DRM 模式 Single Port RAM 模式和 ROM 模式列表</center>


>**Enable Byte Write：** 配置是否使能Byte Write功能， 其含义是Byte写使能，也就是以字节为单位写入数据；Byte Write使能时，同时需要配置字节（Byte）的位宽（Byte Size） 与字节个数（Byte Numbers） ，Byte Size 可选择 8 或者 9； Byte Numbers即配置所使用的 Byte 个数（注：Byte Write使能时，关闭 Address Strobe 功能。）举例说明：输入数据为 32-bit， 字节的位宽（Byte Size）设置为 8bit， 那么就需要 4-bit Byte 写使能信号，这个使能信号与输入数据各位的对应关系如下图所示。从图中不难看出，当 we[3] 有效时，只会将输入数据的高 8-bit 写入到目标地址；当 we[0] 有效时，只会将输入数据的低 8-bit 写入到目标地址。其实，也就是根据写使能来更新指定地址上原始数据的某些位，本小节实验不需要使能 Byte Write 功能即不需要勾选该配置。
><br/>
>![在这里插入图片描述](https://img-blog.csdnimg.cn/d39d3a3514f348feb7aaa8c148e92743.png#pic_center)
><center>Byte 写使能与输入数据的对应关系</center>


>**Address and Data Width Config：** 选项即地址与位宽配置，Address Width 配置地址位宽，Data Width 配置数据位宽。地址位宽合法配置范围为 1~ 20，数据位宽合法配置范围为 1~ 1152，但是所占用的 DRM9K 或者DRM18K 个数必须小于总资源个数。本实验我们配置的地址位宽为 5，数据位宽为 8 位。

>**Enable clk_en Signal：** 配置是否使能 clk_en 信号（注：Clock Enable 与 Address Strobe 功能互斥），本实验未使用保持默认不用勾选。

>**Enable Address Strobe Signal：** 配置是否使能 addr_strobe 信号（注：Byte Write 使能时，关闭 Address Strobe 功能；Clock Enable 与 Address Strobe 功能互斥）, 本实验未使用保持默认不用勾选。

>**Write Mode ：** 配置写模式 。共分为三种模式 ，分别是 NORMAL_WRITE（正常模式）、TRANSPARENT_WRITE（写优先模式）和 READ_BEFORE_WRITE（读优先模式）。正常模式指读写分开操作，不能同时进行读写，本实验选择 NORMAL_WRITE 模式；写优先模式指数据先写入 RAM 中，然后在下一个时钟输出该数据；读优先模式指数据先写入 RAM 中，同时输出 RAM 中同地址的上一次数据。

>**Enable rd_oce Signal：** 配置是否使能 rd_oce（输出寄存器选项）信号，使能 rd_oce 信号时，默认且必须使能读端口输出寄存 “Enable Output Register”，本小节实验不需要使能读信号，所以不勾选该选项。

>**Enable Output Register：** 输出寄存器选项。如果勾选了 “Enable rd_oce Signal” 信号，输出寄存器默认是选中状态，作用是打开 DRM 内部位于输出数据总线之后的输出流水线寄存器，虽然在一般设计中为了改善时序性能会保持此选项的默认勾选状态，但是这会使得 DRM 输出的数据延迟一拍，这不利于我们在调试窗口中直观清晰地观察信号；而且在本实验中我们仅仅是把 DRM 的数据输出总线连接到了调试的探针端口上来进行观察，除此之外数据输出总线没有别的负载，不会带来难以满足的时序路径，因此这里取消勾选。

>**Enable Clock Polarity Invert for Output Register：** 配置是否使能读端口输出时钟极性反向， 使能读端口输出时钟极性反向时，默认且必须使能读端口输出寄存（Enable Output Register），这里不需要使能读端口输出时钟极即不需要勾选该配置。

>**Enable Low Power Mode：** 配置是否使能低功耗模式，本实验不需要配置成低功耗模式，即不勾选使能低功耗模式。

>**Reset Type：** 配置复位方式。"ASYNC" 异步复位，"SYNC" 同步复位，"Sync_Internally " 异步复位同步释放，本实验选择异步复位。

>**Enable Init：** 配置是否使能对当前 RAM 进行初始化，这里不需要该配置即不用勾选使能初始化选项。

>**Init File：** 配置使能对当前 RAM 进行初始化，指定初始化文件路径，若不指定，则生成初始值为全 “0” 的初始化文件.v 文件。

>**File Type：** 配置初始化文件数据格式。"BIN" 二进制，"HEX" 十六进制。

至此本实验所需要的单口 **RAM IP** 已配置完成，接下来点击 “**Customize IP**” 窗口左上角的 “**Generate**” 在弹出的 “**Question**” 对话框选择 “**OK**” 即可，如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/0705b188b26a4b8da15a425a42bde032.png#pic_center)
<center>点击 “Generate” 按钮</center>
<br/>
<br/>



![在这里插入图片描述](https://img-blog.csdnimg.cn/3803722da9da4c48847eb191c1b3c7c9.png#pic_center)
<center>点击 “OK”</center>
<br/>
<br/>

点击 “**OK**” 后打印如下左图信息，至此单口 **RAM IP** 核配置成功，并生成 **ram_1port_tmpl.v** 文件。例化单口 **RAM IP** 时可以使用下图中 **ram_1port_tmpl.v** 文件红框中的代码。


![在这里插入图片描述](https://img-blog.csdnimg.cn/12beab3a2dce49f395a52b25b204bd7b.png#pic_center)
<center>单口 RAM IP 创建成功</center>
<br/>
<br/>

然后如下图所示，关闭 “**Customize IP**” 页面与 “**IP Compiler**” 页面。


![在这里插入图片描述](https://img-blog.csdnimg.cn/35573ba9fcc944e79d5afef2243be547.png#pic_center)

<center>关闭创建 IP 的窗口</center>
<br/>
<br/>


之后我们就可以在 “**Sources**” 窗口的 “**Designs**” 一栏中出现了该 **IP** 核 “**ram_1port**” 如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/38d330a1bbda44be8a0792a992be189c.png#pic_center)
<center>ram_1port IP 核</center>
<br/>
<br/>



至此，我们的 **IP** 核就配置成功了，接下来就根据自己的功能进行代码编写即可，本实验也给大家编写了代码供大家参考，全部工程都在文首的 [Github开源地址](https://github.com/ChinaRyan666/PDS_IP_Set)。







<br/>
<br/>



# 3 双端口 `RAM` IP 核


## 3.1 实验任务

本小节实验任务是使用 **PDS** 的 **IP Compiler** 配置一个简单双端口 **RAM IP** ，使之能进行读写操作。

<br/>


## 3.2 双端口 RAM IP 核简介


根据第二节的讲解，我们了解到了 **RAM IP** 核分为单端口 **RAM** 和双端口 **RAM**，即表示 **RAM IP** 核有几个读写端口。对于单端口 **RAM** 来说，由于读写共用一对地址线，所以没有办法同时读写不同地址的数据；而对于双端口 **RAM** 来说，由于读写地址线是分开的，所以可以同时读写不同地址的数据。

双端口 **RAM** 又分为简单双端口 **RAM** 和真双端口 **RAM**，顾名思义，简单双端口 **RAM** 虽然有两个端口，但是一个端口只能用来写，另一个端口只能用来读，所以简单双端口 **RAM** 也称为伪双端口 **RAM**。而真双端口 **RAM** 是指两个端口都可以用来写或者读，可以理解成具有两个独立的单端口的 **RAM**，一般用于需要多路写入和读出的情况，而不用例化两个单端口的 RAM，在使用上更为方便。

在实际开发应用中，对于单端口 **RAM**、伪双端口 **RAM** 和真双端口 **RAM** 的选择，需要根据项目需求来选择合适的 **RAM**。对于不需要同时读写 **RAM** 的情况，可以选择单端口 **RAM**；对于需要同时读写 **RAM**，但是只需要一路数据写入，一路数据读出的情况，可以选择简单双端口 **RAM**；而对于需要同时读写 **RAM**，有又两个写入或者读出的情况，可以选择真双端口 **RAM**。双端口 **RAM** 一般对于异步数据的缓存使用较多，因此本章使用的是简单双端口 **RAM IP**。

下图为简单双端口 **RAM** 的端口框图。

![在这里插入图片描述](https://img-blog.csdnimg.cn/d0e2022ba4474ec19b954708f2c29d7f.png#pic_center)

<center>简单双端口 RAM 的端口框图</center>
<br/>
<br/>


简单双端口 **RAM** 的端口描述如下：

* **wr_data：** 写数据信号，位宽范围 1~1152；

* **wr_addr：** 写地址信号，位宽范围 5~20；

* **wr_en：** 写使能信号，为高时进行写操作，为低时进行读操作；

* **wr_clk：** 写时钟信号；

* **wr_clk_en：** 写时钟使能信号，为高时对应地址有效，为低时对应地址无效；

* **wr_rst：** 写端口复位信号，高有效；

* **wr_byte_en：** Byte Write 使能信号，当配置 “Enable Byte Write” 选项勾选时有效，位宽范围 1~128。为高时对应 Byte 值有效，为低时对应 Byte 值无效；

* **wr_addr_strobe：** 写地址锁存信号，为高时对应地址无效，上一个地址被保持，为低时对应地址有效；

* **rd_data：** 读数据信号，位宽范围 1~1152；

* **rd_addr：** 读地址信号，位宽范围 5~20；

* **rd_clk：** 读时钟信号；

* **rd_clk_en：** 读时钟使能信号，为高是对应地址有效，为低时对应地址无效；

* **rd_rst：** 读端口复位信号，高有效；

* **rd_oce：** 读数据输出寄存使能信号，为高时对应地址有效，读数据寄存输出，为低时对应地址无效，读数据保持；

* **rd_addr_strobe：** 读地址锁存信号，为高时对应地址无效，上一个地址被保持，为低时对应地址有效。


<br/>


## 3.3 IP 核配置讲解


首先在 **PDS** 软件中创建一个名为 **ip_2port_ram** 的工程，工程创建完成后，在 **PDS** 软件的上方的菜单栏中 “**Tools**” 栏中单击 “**IP Compiler**” 按钮后弹出的 “**IP Compiler**” 窗口如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/50000101e619407782547df162547cfc.png#pic_center)
<center>点击 “IP Compiler”</center>
<br/>
<br/>

![在这里插入图片描述](https://img-blog.csdnimg.cn/27665ab458a34f589f95b4c8e3796bb9.png#pic_center)

<center>“IP Compiler” 窗口</center>
<br/>
<br/>


本实验使用的 **IP** 核路径是 **Module→Memory→DRM→DRM Base Simple Dual Port RAM IP** 核，如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/2e5bb47d3c1c4eee92fdc80a12fc3218.png#pic_center)

<center>DRM Base Simple Dual Port RAM</center>
<br/>
<br/>

点击上图中红框中的 **IP** 后如下图所示：

![在这里插入图片描述](https://img-blog.csdnimg.cn/d0f32f69eec94a2c81999aaa21df0f49.png#pic_center)


<center>DRM Base Simple Dual Port RAM 详情页面</center>
<br/>
<br/>


> **Pathname：** 新建 IP 核在工程所在路径，这里保持默认即可。

> **Instance Name：** 在这里给新建的 RAM IP 命名，我们这里命名为 “ram_2port”。

接下来的 **IP** 框里面的内容是该 **IP** 的基础信息，例如名称、版本号与所属公司（**Pango**）。**Part** 框中的信息为工程所使用的芯片的详细信息。

点击上图中的 “**Customize**” 按钮进入 “**Customize IP**” 窗口对 **RAM IP** 的参数进行配置，“**Customize IP**”窗口界面如下图所示：图中的 “**Add IP**” 弹窗点击“Yes”后进入 “**Customize IP**” 界面进行单口 **RAM** 的参数配置，“**Customize IP**” 界面如下图所示。




![在这里插入图片描述](https://img-blog.csdnimg.cn/f7a14b8d0a134fb6b7f147f595158de1.png#pic_center)

<center>“Add IP” 弹窗</center>
<br/>
<br/>


![在这里插入图片描述](https://img-blog.csdnimg.cn/25bec10d57e744618d3ba896c53eab03.png#pic_center)

<center>"Customize IP" 界面</center>
<br/>
<br/>

**本实验我们主要进行如下配置：**


![在这里插入图片描述](https://img-blog.csdnimg.cn/a283e1ab6c444fd59ac586bc4254ff73.png#pic_center)

<center>DRM Base Simple Dual Port RAM 参数配置界面</center>
<br/>
<br/>

**Customize IP** 界面主要包括如下选项：

>**DRM Resource Usage：** 选项主要说明 DRM 资源使用情况。该选项下的 “DRM Resource Type” 是 DRM 资源类型，可以设置 “AUTO”、“DRM9K”、“DRM18K” 三种模式。三种模式可以根据你需要地址宽度与数据宽度来来设置，一般我们设置为 “AUTO” 模式。
><br/>
>![在这里插入图片描述](https://img-blog.csdnimg.cn/760aefa2a50b4c1c9522b67d6f1a1a7d.png#pic_center)
><center>9Kb DRM 模式下 Simple Dual Port RAM 模式允许的位宽组合</center>
><br/>
>
>![在这里插入图片描述](https://img-blog.csdnimg.cn/713c257a6e794aa2a70cd9ebc19981b3.png#pic_center)
><center>18Kb DRM 模式下 Simple Dual Port RAM 模式允许的位宽组合</center>


>**Write/Read Port Use Same Data Widt：** 配置读写端口是否使用混合位宽模式（注：混合位宽时，关闭 Address Strobe 功能），本实验勾选该选项，使用混合位宽模式，只需要配置写入端口的地址位宽与数据位宽，读端口的地址位宽与数据位宽会与写入端口保持一致。


>**Enable Byte Write：** 配置是否使能 Byte Write 功能，其含义是 Byte 写使能，也就是以字节为单位写入数据；Byte Write使能时，同时需要配置字节（Byte）的位宽（Byte Size）与字节个数（Byte Numbers），Byte Size 可选择 8 或者 9；Byte Numbers 即配置所使用的Byte 个数（注：Byte Write 使能时，关闭 Address Strobe 功能。）举例说明：输入数据为 32-bit，字节的位宽（Byte Size）设置为 8bit， 那么就需要 4-bit Byte 写使能信号，这个使能信号与输入数据各位的对应关系如下图所示。从图中不难看出，当 we[3] 有效时，只会将输入数据的高 8-bit 写入到目标地址；当 we[0] 有效时，只会将输入数据的低 8-bit 写入到目标地址。其实，也就是根据写使能来更新指定地址上原始数据的某些位，本实验不需要使能 Byte Write 功能即不需要勾选该配置。
><br/>
>![在这里插入图片描述](https://img-blog.csdnimg.cn/631ca38cfb484b39bc885f3b8b51272a.png#pic_center)
><center>Byte 写使能与输入数据的对应关系</center>


>**Write Port：** 对写入端口进行配置。Address Width 配置地址位宽，Data Width 配置数据位宽。地址位宽合法配置范围为 5~ 20，数据位宽合法配置范围为 1~ 1152，但是所占用的 DRM9K 或者 DRM18K 个数必须小于总资源个数。本实验我们配置的地址位宽为 5，数据位宽为 8 位。

>**Enable wr_clk_en Signal：** 配置是否使能写端口的 wr_clk_en 信号(注：Clock Enabel 与 Address Strobe 互斥)，本实验未使用保持默认不用勾选。

>**Enable wr_addr_strobe Signal：** 配置是否使能写端口的 wr_addr_strobe 信号(注：Byte Write 使能时，关闭 Address Strobe 功能；混合位宽时，关闭 Address Strobe 功能；Clock Enabel 与 Address Strobe 互斥)，本实验配置使用了混合位宽模式所以关闭 Address Strobe 功能，Enable wr_addr_strobe Signal 选项保持默认不用勾选。

>**Read Port：** 对读出端口进行配置。 Address Width 配置地址位宽，Data Width 配置数据位宽。地址位宽合法配置范围为 5~ 20，数据位宽合法配置范围为 1~ 1152，但是所占用的 DRM9K 或者 DRM18K 个数必须小于总资源个数。本实验我们配置使用了混合位宽模式，所以读端口的地址位宽与数据位宽会直接与写端口的配置保持一致。

>**Enable rd_clk_en Signal：** 配置是否使能读端口的 rd_clk_en 信号（注：Clock Enabel 与 Address Strobe 互斥），本实验未使用保持默认不用勾选。

>**Enable rd_addr_strobe Signal：** 配置是否使能读端口的 rd_addr_strobe 信号(注：Byte Write 使能时，关闭Address Strobe 功能；混合位宽时，关闭 Address Strobe 功能；Clock Enabel 与 Address Strobe 互斥)，本实验配置使用了混合位宽模式所以关闭 Address Strobe 功能， Enable rd_addr_strobe Signal 选项保持默认不用勾选。

>**Enable rd_oce Signal：** 配置是否使能 rd_oce（输出寄存器选项）信号，使能 rd_oce 信号时，默认且必须使能读端口输出寄存 “Enable Output Register”，本实验不需要使能读信号，所以不勾选该选项。

>**Enable Output Register：** 输出寄存器选项。如果勾选了 “Enable rd_oce Signal” 信号，输出寄存器默认是选中状态，作用是打开 DRM 内部位于输出数据总线之后的输出流水线寄存器， 虽然在一般设计中为了改善时序性能会保持此选项的默认勾选状态，但是这会使得 BRM 输出的数据延迟一拍，这不利于我们在调试窗口中直观清晰地观察信号； 而且在本实验中我们仅仅是把 BRM 的数据输出总线连接到了调试的探针端口上来进行观察，除此之外数据输出总线没有别的负载，不会带来难以满足的时序路径，因此这里取消勾选。

>**Enable Clock Polarity Invert for Output Register：** 配置是否使能读端口输出时钟极性反向， 使能读端口输出时钟极性反向时，默认且必须使能读端口输出寄存（Enable Output Register），这里不需要使能读端口输出时钟极即不需要勾选该配置。

>**Enable Low Power Mode：** 配置是否使能低功耗模式，本实验不需要配置成低功耗模式，即不勾选使能低功耗模式。

>**Reset Type：** 配置复位方式。"ASYNC"异步复位，"SYNC"同步复位，"Sync_Internally " 异步复位同步释放，本实验选择异步复位。

>**Enable Init：** 配置是否使能对当前 RAM 进行初始化，这里不需要该配置即不用勾选使能初始化选项。

>**Init File：** 配置使能对当前 RAM 进行初始化，指定初始化文件路径，若不指定，则生成初始值为全 “0” 的初始化文件`.v` 文件。

>**File Type：** 配置初始化文件数据格式。"BIN" 二进制，"HEX" 十六进制。

至此本实验所需要的简单双单口 **RAM IP** 已配置完成， 接下来点击 “**Customize IP**” 窗口左上角的 “**Generate**” 在弹出的 “**Question**” 对话框选择 “**OK**” 即可，如下图所示。



![在这里插入图片描述](https://img-blog.csdnimg.cn/63fdd01f4c354b83bb753baadb4716d0.png#pic_center)
<center>点击 “Generate” 按钮</center>
<br/>
<br/>





点击 “**OK**” 后打印如下左图信息，至此简单双单口 **RAM IP** 核配置成功，并生成 **ram_2port_tmpl.v** 文件。例化简单双单口 **RAM IP** 时可以使用下图中 **ram_2port_tmpl.v** 文件红框中的代码。






![在这里插入图片描述](https://img-blog.csdnimg.cn/50919bcc33634c8bacacdf02dfb04290.png#pic_center)
<center>简单双端口 RAM IP 创建成功</center>
<br/>
<br/>

然后如下图所示，关闭 “**Customize IP**” 页面与 “**IP Compiler**” 页面。

![在这里插入图片描述](https://img-blog.csdnimg.cn/483225e60f1249ceb0d31db3f8eeef19.png#pic_center)


<center>关闭创建 IP 的窗口</center>
<br/>
<br/>

之后我们就可以在 “**Sources**” 窗口的 “**Designs**” 一栏中出现了该 **IP** 核 “**pll_clk**” 如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/3887b457c14d4a5097f80d37824b6716.png#pic_center)

<center>"ram_2port" IP</center>
<br/>
<br/>


至此，我们的 **IP** 核就配置成功了，接下来就根据自己的功能进行代码编写即可，本实验也给大家编写了代码供大家参考，全部工程都在文首的 [Github开源地址](https://github.com/ChinaRyan666/PDS_IP_Set)。







<br/>
<br/>


# 4 `FIFO` IP 核


## 4.1 实验任务

本节的实验任务是使用 **Pango** 生成 **FIFO IP** 核，并实现以下功能：当 **FIFO** 为空时，向 **FIFO** 中写入数据，写入的数据量和 **FIFO** 深度一致，即 **FIFO** 被写满；然后从 **FIFO** 中读出数据，直到 **FIFO** 被读空为止，以此向大家详细介绍一下 **FIFO IP** 核的使用方法。


<br/>

## 4.2 FIFO IP 核简介

**FIFO** 的英文全称是 **First In First Out**，即先进先出。**FPGA** 使用的 **FIFO** 一般指的是对数据的存储具有先进先出特性的一个缓存器，常被用于数据的缓存，或者高速异步数据的交互也即所谓的**跨时钟域信号传递**。它与 **FPGA** 内部的 **RAM** 和 **ROM** 的区别是**没有外部读写地址线**，采取**顺序写入**数据，**顺序读出**数据的方式，使用起来简单方便，由此带来的缺点就是不能像 **RAM** 和 **ROM** 那样可以由地址线决定读取或写入某个指定的地址。


根据 **FIFO** 工作的时钟域，可以将 **FIFO** 分为**同步 FIFO** 和**异步 FIFO**。同步 **FIFO** 是指读时钟和写时钟为同一个时钟，在时钟沿来临时同时发生读写操作。异步 **FIFO** 是指读写时钟不一致，读写时钟是互相独立的。**Pango** 的 **FIFO IP** 核可以被配置为同步 **FIFO** 或异步 **FIFO**，其信号框图如下图所示。

从图中可以了解到，当被配置为**同步 FIFO** 时，只使用 **wr_clk**，所有的输入输出信号都同步于 **wr_clk** 信号。而当被配置为异步 **FIFO** 时，写端口和读端口分别有独立的时钟，所有与写相关的信号都是同步于写时钟 **wr_clk**，所有与读相关的信号都是同步于读时钟 **rd_clk**。


![在这里插入图片描述](https://img-blog.csdnimg.cn/e532563834174c799f7359b2026e063f.png#pic_center)

<center>Pango 的 FIFO IP 核的信号框图</center>
<br/>
<br/>







对于 **FIFO** 需要了解一些常见参数：

* **FIFO 的宽度：** FIFO 一次读写操作的数据位 N。

* **FIFO 的深度：** FIFO 可以存储多少个宽度为 N 位的数据。

* **将空标志：** almost_empty。 FIFO 即将被读空。

* **空标志：** rd_empty。FIFO 已空时由 FIFO 的状态电路送出的一个信号，以阻止 FIFO 的读操作继续从 FIFO 中读出数据而造成无效数据的读出。

* **将满标志：** almost_full。FIFO 即将被写满。

* **满标志：** wr_full。FIFO 已满或将要写满时由 FIFO 的状态电路送出的一个信号，以阻止 FIFO 的写操作继续向 FIFO 中写数据而造成溢出。

* **读时钟：** 读 FIFO 时所遵循的时钟，在每个时钟的上升沿触发。

* **写时钟：** 写 FIFO 时所遵循的时钟，在每个时钟的上升沿触发。

这里请注意，“**almost_empty**” 和 “**almost_full**” 这两个信号分别被看作 “**empty**” 和 “**full**” 的警告信号，他们相对于真正的空（**empty**）和满（**full**）都会提前一个时钟周期拉高。

对于 **FIFO** 的基本知识先了解这些就足够了，可能有人会好奇为什么会有同步 **FIFO** 和异步 **FIFO**，它们各自的用途是什么。之所以有**同步 FIFO** 和**异步 FIFO** 是因为各自的作用不同。

同步 **FIFO** 常用于同步时钟的数据缓存，异步 **FIFO** 常用于跨时钟域的数据信号的传递，例如时钟域 **A** 下的数据 **data1** 传递给异步时钟域 **B**，当 **data1** 为连续变化信号时，如果直接传递给时钟域 **B** 则可能会导致收非所送的情况，即在采集过程中会出现包括亚稳态问题在内的一系列问题，使用异步 **FIFO** 能够将不同时钟域中的数据同步到所需的时钟域中。

<br/>

## 4.3 IP 核配置讲解

首先在 **PDS** 软件中创建一个名为 **ip_fifo** 的工程，工程创建完成后，在 **PDS** 软件的上方的菜单栏中 “**Tools**” 栏中单击 “**IP Compiler**” 按钮后弹出的 “**IP Compiler**” 窗口如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/db175c0c75204c879a8e2c01a7763025.png#pic_center)
<center>点击 “IP Compiler”</center>
<br/>
<br/>

![在这里插入图片描述](https://img-blog.csdnimg.cn/41a7768b72fb416e97d791ad7eb0f602.png#pic_center)
<center>“IP Compiler” 窗口</center>
<br/>
<br/>



本实验使用的 **IP** 核路径是 **Module→Memory→DRM→DRM Base FIFO**，如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/b4da282f3ef74be0b6ca44ed596e72df.png#pic_center)

<center>DRM Base FIFO IP</center>
<br/>
<br/>



点击上图中红框中的 **IP** 后如下图所示：



![在这里插入图片描述](https://img-blog.csdnimg.cn/bf7b7f30b67b4e708dad3e3318a0a073.png#pic_center)

<center>DRM Base FIFO 详情页面</center>
<br/>
<br/>



>**Pathname：** 新建 IP 核在工程所在路径，这里保持默认即可。

>**Instance Name：** 在这里给新建的 FIFO IP 命名，我们这里命名为 “fifo_generator_0”。接下来的 IP 框里面的内容是该 IP 的基础信息，例如名称、版本号与所属公司（Pango）。Part 框中的信息为工程所使用的芯片的详细信息。

点击上图中的 “**Customize**” 按钮进入 “**Customize IP**” 窗口对 **FIFO IP** 的参数进行配置，“**Customize IP**” 窗口界面如下图所示：图中的 “**Add IP**” 弹窗点击 “**Yes**” 后进入 “**Customize IP**” 界面进行异步 **FIFO** 的参数配置，“**Customize IP**” 界面如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/56410c8ea2ca41d9b79a7ea6226f7fad.png#pic_center)
<center>“Add IP” 弹窗</center>
<br/>
<br/>


![在这里插入图片描述](https://img-blog.csdnimg.cn/e686329ce84a4684a86bedd6d43447f6.png#pic_center)

<center>"Customize IP" 界面</center>
<br/>
<br/>


**本实验我们主要进行如下配置：**


![在这里插入图片描述](https://img-blog.csdnimg.cn/86c721fa9481491c8a0d7d93d3149214.png#pic_center)

<center>DRM Base FIFO 参数配置界面</center>
<br/>
<br/>




**Customize IP** 界面主要包括如下选项：

>**DRM Resource Usage：** 选项主要说明 DRM 资源使用情况。该选项下的 “DRM Resource Type” 是 DRM 资源类型，可以设置 “AUTO”、“DRM9K”、“DRM18K” 三种模式。三种模式可以根据你需要地址宽度与数据宽度来来设置，一般我们设置为 “AUTO” 模式。

>**Write/Read Port Use Same Data Widt：** 配置读写端口是否使用混合位宽模式（注：混合位宽时，关闭 Address Strobe 功能），本实验勾选该选项，使用混合位宽模式，只需要配置写入端口的地址位宽与数据位宽，读端口的地址位宽与数据位宽会与写入端口保持一致。

>**FIFO Type：** FIFO 可以配置的类型有两种，"ASYN_FIFO" 异步 FIFO 和 "SYNC_FIFO" 同步 FIFO，本实验配置的是异步 FIFO 类型。

>**Enable Byte Write：** 配置是否使能 Byte Write 功能， 其含义是 Byte 写使能，也就是以字节为单位写入数据；Byte Write 使能时，同时需要配置字节（Byte）的位宽（Byte Size）与字节个数（Byte Numbers），Byte Size 可选择 8 或者 9；Byte Numbers 即配置所使用的 Byte 个数（注：Byte Write 使能时，关闭 Address Strobe 功能。）举例说明：输入数据为 32-bit， 字节的位宽（Byte Size）设置为 8bit， 那么就需要 4-bit Byte 写使能信号，这个使能信号与输入数据各位的对应关系如下图所示。从图中不难看出，当 we[3] 有效时，只会将输入数据的高 8-bit 写入到目标地址；当 we[0] 有效时，只会将输入数据的低 8-bit 写入到目标地址。其实，也就是根据写使能来更新指定地址上原始数据的某些位，本实验不需要使能 Byte Write 功能即不需要勾选该配置。
><br/>
>![在这里插入图片描述](https://img-blog.csdnimg.cn/66dcb1bfdda343f0ae43a4f152f64a56.png#pic_center)
><center>Byte 写使能与输入数据的对应关系</center>



>**Write Port：** 对写入端口进行配置。 Address Width 配置地址位宽， Data Width 配置数据位宽。地址位宽合法配置范围为 5~ 20，数据位宽合法配置范围为 1~1152，但是所占用的 DRM9K 或者 DRM18K 个数必须小于总资源个数。本实验我们配置的地址位宽为 5，数据位宽为 8位。

>**Read Port：** 对读出端口进行配置。 Address Width 配置地址位宽， Data Width 配置数据位宽。地址位宽合法配置范围为 5~ 20，数据位宽合法配置范围为 1~1152，但是所占用的 DRM9K 或者 DRM18K 个数必须小于总资源个数。本实验我们配置使用了混合位宽模式，所以读端口的地址位宽与数据位宽会直接与写端口的配置保持一致。

>**Enable Almost Full Water Level：** 配置是否使能 wr_water_level 信号， 使能 wr_water_level 信号可以对写端口数据进行计数， 本实验配置使能写端口计数。

>**Enable Almost Empty Water Level：** 配置是否使能 wr_empty_level 信号， 使能 wr_empty_level 信号可以对读端口数据进行计数，本实验配置使能读端口计数。

>**Almost Full Numbers：** 配置 FIFO Almost Full 个数， 设置为该选项后面的允许的最大值。

>**Almost Empty Numbers：** 配置 FIFO Almost Empty 个数， 设置为该选项后面的允许的最小值。

>**Enable rd_oce Signal：** 配置是否使能 rd_oce（输出寄存器选项）信号，输出寄存使能信号为高时对应地址有效，读数据会寄存输出，若输出寄存使能信号为低时对应地址无效，读数据保持。 并且使能 rd_oce 信号时，默认且必须使能读端口输出寄存 “Enable Output Register”，本实验不需要使能读信号，所以不勾选该选项。

>**Enable Output Register：** 输出寄存器选项。如果勾选了 “Enable rd_oce Signal” 信号，输出寄存器默认是选中状态，作用是打开 DRM 内部位于输出数据总线之后的输出流水线寄存器， 虽然在一般设计中为了改善时序性能会保持此选项的默认勾选状态，但是这会使得 BRM 输出的数据延迟一拍，这不利于我们在调试窗口中直观清晰地观察信号；而且在本实验中我们仅仅是把 BRM 的数据输出总线连接到了调试的探针端口上来进行观察，除此之外数据输出总线没有别的负载，不会带来难以满足的时序路径，因此这里取消勾选。

>**Enable Clock Polarity Invert for Output Register：** 配置是否使能读端口输出时钟极性反向， 使能读端口输出时钟极性反向时，默认且必须使能读端口输出寄存（Enable Output Register），这里不需要使能读端口输出时钟极即不需要勾选该配置。

>**Enable Low Power Mode：** 配置是否使能低功耗模式，本实验不需要配置成低功耗模式，即不勾选使能低功耗模式。

>**Reset Type：** 配置复位方式："ASYNC"异步复位，"SYNC"同步复位，"Sync_Internally " 异步复位同步释放，本实验选择异步复位（低有效）。

至此本实验所需要的异步 **FIFO IP** 已配置完成， 接下来点击 “**Customize IP**” 窗口左上角的 “**Generate**” 在弹出的 “**Question**” 对话框选择 “**OK**” 即可，如下图所示。


![在这里插入图片描述](https://img-blog.csdnimg.cn/87d1b192f53143d2867398bb5a1f1b50.png#pic_center)

<center>点击 “OK”</center>
<br/>
<br/>




点击 “**OK**” 后打印如下左图信息，至此 **FIFO IP** 核配置成功，并生成 **fifo_generator_0_tmpl.v** 文件。例化 **FIFO IP** 时可以使用下图中**fifo_generator_0_tmpl.v** 文件红框中的代码。


![在这里插入图片描述](https://img-blog.csdnimg.cn/bdd9f61bc446478c9ba6be3c0e0312c5.png#pic_center)

<center>FIFO IP 创建成功</center>
<br/>
<br/>




然后如下图所示，关闭 “**Customize IP**” 页面与 “**IP Compiler**” 页面。


![在这里插入图片描述](https://img-blog.csdnimg.cn/10014b708cef4772aa93a5be329f0e24.png#pic_center)

<center>关闭创建 IP 的窗口</center>
<br/>
<br/>




之后我们就可以在 “**Sources**” 窗口的 “**Designs**” 一栏中出现了该 **IP** 核 “**fifo_generator_0**” 如下图所示。

![在这里插入图片描述](https://img-blog.csdnimg.cn/576ff3a9c0a942a09776dc5239c3a7ef.png#pic_center)


<center>FIFO IP 核</center>
<br/>
<br/>





至此，我们的 **IP** 核就配置成功了，接下来就根据自己的功能进行代码编写即可，本实验也给大家编写了代码供大家参考，全部工程都在文首的 [Github开源地址](https://github.com/ChinaRyan666/PDS_IP_Set)。



<br/>
<br/>







# 5 总结

本篇博客我使用四个小实验，带大家简单过了遍 **PDS** 中四个常用 **IP** 核的理解和配置，以此抛砖引玉。建议大家可以再去读读 **IP** 对应的手册，紫光同创的 **PDS** 软件在 **IP** 核的配置上对用户还是非常友好的。本次提到的四个实验也有对应的源码工程，我都一起上传到本篇博客的[开源地址](https://github.com/ChinaRyan666/PDS_IP_Set)了，欢迎大家 **Fork** 到本地学习~~












希望以上的内容对您有所帮助，**诚挚**地欢迎各位读者在评论区或者私信我交流！


微博：沂舟Ryan ([@沂舟Ryan 的个人主页 - 微博 ](https://weibo.com/u/7619968945))

GitHub：[ChinaRyan666](https://github.com/ChinaRyan666)

微信公众号：**沂舟无限进步**（内含精品资料及详细教程）

如果对您有帮助的话请点赞支持下吧！



**集中一点，登峰造极。**
