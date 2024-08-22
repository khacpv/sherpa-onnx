import Foundation

func getResource(_ forResource: String, _ ofType: String) -> String {
  let path = Bundle.main.path(forResource: forResource, ofType: ofType)
  precondition(
    path != nil,
    "\(forResource).\(ofType) does not exist!\n" + "Remember to change \n"
      + "  Build Phases -> Copy Bundle Resources\n" + "to add it!"
  )
  return path!
}
/// Please refer to
/// https://k2-fsa.github.io/sherpa/onnx/pretrained_models/index.html
/// to download pre-trained models

/// sherpa-onnx-streaming-zipformer-bilingual-zh-en-2023-02-20 (Bilingual, Chinese + English)
/// https://k2-fsa.github.io/sherpa/onnx/pretrained_models/zipformer-transducer-models.html
func getBilingualStreamZhEnZipformer20230220() -> SherpaOnnxOnlineModelConfig {
  let encoder = getResource("encoder-epoch-99-avg-1", "onnx")
  let decoder = getResource("decoder-epoch-99-avg-1", "onnx")
  let joiner = getResource("joiner-epoch-99-avg-1", "onnx")
  let tokens = getResource("tokens", "txt")

  return sherpaOnnxOnlineModelConfig(
    tokens: tokens,
    transducer: sherpaOnnxOnlineTransducerModelConfig(
      encoder: encoder,
      decoder: decoder,
      joiner: joiner
    ),
    numThreads: 1,
    modelType: "zipformer"
  )
}

func getTtsForVCTK() -> SherpaOnnxOfflineTtsWrapper {
  // See the following link
  // https://k2-fsa.github.io/sherpa/onnx/tts/pretrained_models/vits.html#vctk-english-multi-speaker-109-speakers

  // vits-vctk.onnx
  let model = getResource("vits-vctk", "onnx")

  // lexicon.txt
  let lexicon = getResource("vits-vctk_lexicon", "txt")

  // tokens.txt
  let tokens = getResource("vits-vctk_tokens", "txt")

  let vits = sherpaOnnxOfflineTtsVitsModelConfig(model: model, lexicon: lexicon, tokens: tokens)
  let modelConfig = sherpaOnnxOfflineTtsModelConfig(vits: vits)
  var config = sherpaOnnxOfflineTtsConfig(model: modelConfig)
  return SherpaOnnxOfflineTtsWrapper(config: &config)
}

func getTtsForVitPiper() -> SherpaOnnxOfflineTtsWrapper {
    // See the following link
    // https://k2-fsa.github.io/sherpa/onnx/tts/pretrained_models/vits.html#vctk-english-multi-speaker-109-speakers
    
    // vits-vctk.onnx
    let model = getResource("en_US-libritts_r-medium", "onnx")
    
    // tokens.txt
    let tokens = getResource("en_US-libritts_r-medium", "txt")
    
    // data folder
    let data_dir = Bundle.main.path(forResource: "espeak-ng-data", ofType: nil)
    
    let vits = sherpaOnnxOfflineTtsVitsModelConfig(model: model, lexicon: "", tokens: tokens, dataDir: data_dir!)

    let modelConfig = sherpaOnnxOfflineTtsModelConfig(vits: vits)
    var config = sherpaOnnxOfflineTtsConfig(model: modelConfig)
    return SherpaOnnxOfflineTtsWrapper(config: &config)
}

func getTtsForVitPiperHigh() -> SherpaOnnxOfflineTtsWrapper {
    // See the following link
    // https://k2-fsa.github.io/sherpa/onnx/tts/pretrained_models/vits.html#vctk-english-multi-speaker-109-speakers
    
    // vits-vctk.onnx
    let model = getResource("vits-piper-en_US-libritts-high.onnx", "onnx")
    
    // tokens.txt
    let tokens = getResource("vits-piper-en_US-libritts-high_tokens", "txt")
    
    // data folder
    let data_dir = Bundle.main.path(forResource: "espeak-ng-data", ofType: nil)
    
    let vits = sherpaOnnxOfflineTtsVitsModelConfig(model: model, lexicon: "", tokens: tokens, dataDir: data_dir!)

    let modelConfig = sherpaOnnxOfflineTtsModelConfig(vits: vits)
    var config = sherpaOnnxOfflineTtsConfig(model: modelConfig)
    return SherpaOnnxOfflineTtsWrapper(config: &config)
}

func getTtsForVitPiperVN() -> SherpaOnnxOfflineTtsWrapper {
    // See the following link
    // https://k2-fsa.github.io/sherpa/onnx/tts/pretrained_models/vits.html#vctk-english-multi-speaker-109-speakers
    
    // vits-vctk.onnx
    let model = getResource("vi_VN-vivos-x_low", "onnx")
    
    // tokens.txt
    let tokens = getResource("vi_VN-vivos-x_low_tokens", "txt")
    
    // data folder
    let data_dir = Bundle.main.path(forResource: "espeak-ng-data", ofType: nil)
    
    let vits = sherpaOnnxOfflineTtsVitsModelConfig(model: model, lexicon: "", tokens: tokens, dataDir: data_dir!)

    let modelConfig = sherpaOnnxOfflineTtsModelConfig(vits: vits)
    var config = sherpaOnnxOfflineTtsConfig(model: modelConfig)
    return SherpaOnnxOfflineTtsWrapper(config: &config)
}

func getTtsForVitCoqui() -> SherpaOnnxOfflineTtsWrapper {
    // See the following link
    // https://k2-fsa.github.io/sherpa/onnx/tts/pretrained_models/vits.html#vctk-english-multi-speaker-109-speakers
    
    // vits-vctk.onnx
    let model = getResource("vits-coqui-es-css10-tts_model", "onnx")
    
    // tokens.txt
    let tokens = getResource("vits-coqui-es-css10-tts_tokens", "txt")
    
    let vits = sherpaOnnxOfflineTtsVitsModelConfig(model: model, lexicon: "", tokens: tokens)

    let modelConfig = sherpaOnnxOfflineTtsModelConfig(vits: vits)
    var config = sherpaOnnxOfflineTtsConfig(model: modelConfig)
    return SherpaOnnxOfflineTtsWrapper(config: &config)
}

func getTtsForMimic3VN() -> SherpaOnnxOfflineTtsWrapper {
    // See the following link
    // https://k2-fsa.github.io/sherpa/onnx/tts/pretrained_models/vits.html#vctk-english-multi-speaker-109-speakers
    
    // vits-vctk.onnx
    let model = getResource("vits-mimic3-vi_VN-vais1000_low", "onnx")
    
    // tokens.txt
    let tokens = getResource("vits-mimic3-vi_VN-vais1000_low_tokens", "txt")
    
    // data folder
    let data_dir = Bundle.main.path(forResource: "espeak-ng-data", ofType: nil)
    
    let vits = sherpaOnnxOfflineTtsVitsModelConfig(model: model, lexicon: "", tokens: tokens, dataDir: data_dir!)

    let modelConfig = sherpaOnnxOfflineTtsModelConfig(vits: vits)
    var config = sherpaOnnxOfflineTtsConfig(model: modelConfig)
    return SherpaOnnxOfflineTtsWrapper(config: &config)
}

func getZhZipformer20230615() -> SherpaOnnxOnlineModelConfig {
  let encoder = getResource("encoder-epoch-12-avg-4-chunk-16-left-128", "onnx")
  let decoder = getResource("decoder-epoch-12-avg-4-chunk-16-left-128", "onnx")
  let joiner = getResource("joiner-epoch-12-avg-4-chunk-16-left-128", "onnx")
  let tokens = getResource("tokens", "txt")

  return sherpaOnnxOnlineModelConfig(
    tokens: tokens,
    transducer: sherpaOnnxOnlineTransducerModelConfig(
      encoder: encoder,
      decoder: decoder,
      joiner: joiner
    ),
    numThreads: 1,
    modelType: "zipformer2"
  )
}

func getZhZipformer20230615Int8() -> SherpaOnnxOnlineModelConfig {
  let encoder = getResource("encoder-epoch-12-avg-4-chunk-16-left-128.int8", "onnx")
  let decoder = getResource("decoder-epoch-12-avg-4-chunk-16-left-128", "onnx")
  let joiner = getResource("joiner-epoch-12-avg-4-chunk-16-left-128", "onnx")
  let tokens = getResource("tokens", "txt")

  return sherpaOnnxOnlineModelConfig(
    tokens: tokens,
    transducer: sherpaOnnxOnlineTransducerModelConfig(
      encoder: encoder,
      decoder: decoder,
      joiner: joiner),
    numThreads: 1,
    modelType: "zipformer2"
  )
}

func getEnZipformer20230626() -> SherpaOnnxOnlineModelConfig {
  let encoder = getResource("encoder-epoch-99-avg-1-chunk-16-left-128", "onnx")
  let decoder = getResource("decoder-epoch-99-avg-1-chunk-16-left-128", "onnx")
  let joiner = getResource("joiner-epoch-99-avg-1-chunk-16-left-128", "onnx")
  let tokens = getResource("tokens", "txt")

  return sherpaOnnxOnlineModelConfig(
    tokens: tokens,
    transducer: sherpaOnnxOnlineTransducerModelConfig(
      encoder: encoder,
      decoder: decoder,
      joiner: joiner),
    numThreads: 1,
    modelType: "zipformer2"
  )
}

func getBilingualStreamingZhEnParaformer() -> SherpaOnnxOnlineModelConfig {
  let encoder = getResource("encoder.int8", "onnx")
  let decoder = getResource("decoder.int8", "onnx")
  let tokens = getResource("tokens", "txt")

  return sherpaOnnxOnlineModelConfig(
    tokens: tokens,
    paraformer: sherpaOnnxOnlineParaformerModelConfig(
      encoder: encoder,
      decoder: decoder),
    numThreads: 1,
    modelType: "paraformer"
  )
}

/// Please refer to
/// https://k2-fsa.github.io/sherpa/onnx/pretrained_models/index.html
/// to add more models if you need
