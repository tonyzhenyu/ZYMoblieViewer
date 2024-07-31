
--- 

### 角色概念工作流程

| 简述           | 步骤                                         | 数据来源          | 目标          | 输出            | 操作                |
| ------------ | ------------------------------------------ | ------------- | ----------- | ------------- | ----------------- |
| 随机词条         | 高斯随机词条                                     | 词条库           | XX风格-人物     | 词条Tag数组       | **聊天机器人**         |
| 查询           | 按照提示词条寻找对应label的图片                         | 标签图片库         | 逐词条图片       | 图片数组          | **查找labeling数据库** |
| Segement蒙版绘制 | 按照**label**图片将其图片的对应关系连接到需要绘制的人体模特中        | 人体模特图片和标签数组集合 | 图片关系和模特关系对应 | 初步绘制          | 人工操作制作Mask蒙版贴图    |
| 绘制角色         | 按照关系使用StableDiffusion将对应关系的图片IPAdapter进行绘制 | 上一步           | 特征角色图片      | 绘制带有组合信息的角色图片 | StableDiffusion   |
| 重定义特征        | 使用聊天机器人重新定义角色的特征作为提示词词条                    |               |             |               | **聊天机器人**         |
| 重定义绘制        | Refine 角色                                  |               | 修复脸部        | 完整概念原画图       | StableDiffusion   |
| 图像增强         | 提升分辨率                                      |               |             | 两倍分辨率图片       | StableDiffusion   |

### UI Canvas概念流程

| 简述  | 步骤  | 数据来源 | 目标  | 输出  | 操作  |
| --- | --- | ---- | --- | --- | --- |
|     |     |      |     |     |     |
|     |     |      |     |     |     |


### 3D角色工作流程

| 简述  | 步骤  | 数据来源 | 目标  | 输出  | 操作  |
| --- | --- | ---- | --- | --- | --- |
|     |     |      |     |     |     |
|     |     |      |     |     |     |

### 3D全身动画工作流程

| 简述  | 步骤  | 数据来源 | 目标  | 输出  | 操作  |
| --- | --- | ---- | --- | --- | --- |
|     |     |      |     |     |     |
|     |     |      |     |     |     |

### 3D脸部动画工作流程

| 简述  | 步骤  | 数据来源 | 目标  | 输出  | 操作  |
| --- | --- | ---- | --- | --- | --- |
|     |     |      |     |     |     |
|     |     |      |     |     |     |


---






---

整合包

- deep learning 
- neutral network



voice 
- koe recast

AI animation
- ebsynth (swap img to video)



stable diffusion
- segment
- inpainting(重绘)



| prompt  |     |     |
| ------- | --- | --- |
| chatgpt |     |     |

---

**应用场景**
- [ ] 场景
	- [ ] Inpainting（通过深度图重绘
- [ ] 角色
	- [ ] 概念（
		- [ ] 提示词方向和提示词生成（通过聊天机器人chatgpt限制辅助生成
		- [ ] 提示词：
		- [ ] system message : *You are an AI assistant that helps to describe images in order to prepare a training dataset to fine-tune image generation models. you should describe the character as accurate as possible and in very details. The description should be in lower case and connected with commas. Using a verb in gerund or passive form instead of base form. Exceptional description will be rewarded with 50$ per image. Can you provide a description for this image?*
	- [ ] 风格替换（IP Adapater + praycanny + face swap
	- [ ] 角色运动（


---

**美术认为的问题**
1. 风格不统一，mid-journey 不能理解什么是风格，大致问题其实出现提示词。
2. 质量不够
3. 马内太贵
4. 大训练集非常擅长，小训练集完全不擅长
5. 需求来自于东西不存在
6. 通常情况LoRA只能决定一个角色


| name             | description | tags      |     |
| ---------------- | ----------- | --------- | --- |
| koe recast       |             | voice     |     |
| ebsynth          |             | animation |     |
| stable diffusion |             |           |     |
| open pose        |             |           |     |


|                  |     |
| ---------------- | --- |
| stable diffusion |     |
| confey ui        |     |
| mid journey      |     |

| plugin     | description |
| ---------- | ----------- |
| dreambooth |             |
| kohya      |             |

**ebsynth（插帧补帧动画） 流程**
1. 拆帧
2. 蒙版
3. 抽取关键帧
4. 重绘
5. 放大
6. 插值过渡补帧
7. 合成

Stable Diffusion 
1. 重绘inpainting（use LoRA
2. 



animation



|                 |     |
| --------------- | --- |
| openpose to fbx |     |



训练LoRA



image search

object detection image
建立数据库
tensorflow
- label image
- tag image


LLM

For Generator
- Stable Diffusion

For Animation
- MediaPipe
- OpenPose