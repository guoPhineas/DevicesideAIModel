## Model Preparing

[简体中文](./Readme_zh.md)

> [!Important]
>
> Please be sure to prepare the model yourself as described in this instruction
>
> This project uses Qwen3-4B for a demo. You can choose other models to run.

### Preparing the Environment and Model

First, note that you need to install the Metal Toolchain – this can be done in Xcode > Settings.

The coreai-models package is in this project, navigate to the package folder in the terminal and run:

```shell
uv run coreai.llm.export Qwen/Qwen3-4B --platform iOS
```

This will download the Qwen3-4B model from Hugging Face, convert it to an `.aimodel` file optimized for iOS, and generate dedicated metadata and a tokenizer.

> You can also download other models. For specific usage, refer to the documentation for each model in the `models` folder of the coreai-models project.

Once you have these three files/folders, we need to pre-compile the `.aimodel`. Attention: You can leave the `.aimodel` as-is and add it directly to your project, but this will increase launch time each time, and the model will be specialized and compiled to disk on every launch – wasting both time and storage space. The fact that it recompiles on every launch appears to be a bug.

I highly recommend pre-compiling for each architecture in advance, as this also improves runtime performance:

```Shell
xcrun coreai-build compile MyModel.aimodel --platform iOS --min-deployment-version 27.0 --output compiled/
```

After running this, the `compiled/` folder will contain 11 architecture-specific `.aimodelc` files (the number may vary), each named following the format `MyModel.<arch>.aimodelc`, where `<arch>` is the architecture name. You can retrieve this value at runtime using `AIModel.deviceArchitectureName`. Typically, models are not distributed with the app bundle – instead, they are downloaded from the backend based on the `deviceArchitectureName`. Of course, you can also export a specific architecture by adding the `--architecture <arch>` flag.

Model compiled for a specific architecture (M2):

![Model compiled for a specific architecture](../../imgs/1.png)

For demonstration purposes, we'll include the architecture-specific model files directly in the Bundle. Place the three downloaded files/folders into a single folder (replace the `.aimodel` file with the corresponding `.aimodelc` from the previous step, and update `assets.main` in `metadata.json` to point to the `.aimodelc` filename), then drag the folder into your Xcode project. Make sure to set the Bundle Rule to `Apply Once to Folder` and set the Target Membership. This will copy the entire folder into the Bundle.

![](../../imgs/2.png)

![](../../imgs/3.png)

### Code Integration

First, we need to load the model folder. Get the folder URL from the Bundle:

```Swift
let folderPath = Bundle.main.path(forResource: "QwenAI", ofType: nil)!
let folderURL = URL(fileURLWithPath: folderPath)
```

Then, load the large language model from the model folder:

```Swift
model = try await CoreAILanguageModel(resourcesAt: folderURL)
try await model.load()
```

The `load()` method loads the model into memory, which can be quite large. On first run, it will also generate a device‑specific specialized model file and save it to the app's sandbox. This step usually takes a while.

After loading, initialize a session with the model:

```Swift
session = LanguageModelSession(model: model, instructions: "You are an assistant that...") // See the Foundation Model documentation for parameter details
```

Now you can start making calls. `LanguageModelSession` is a class from the Foundation Model framework. It works the same way as using the built‑in model. You can use the `@Generable` macro or call the output directly. For example:

```Swift
session.respond(to: "Hello").content

// Or streaming output
session.streamResponse(to: msg)
```

I won't go into more detail here – please refer to the documentation or WWDC videos.

### Running

One important note: you should run in a Release build configuration, not Debug. The Debug configuration will be significantly slower.