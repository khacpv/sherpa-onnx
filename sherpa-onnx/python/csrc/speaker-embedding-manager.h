// sherpa-onnx/python/csrc/speaker-embedding-manager.h
//
// Copyright (c)  2023  Xiaomi Corporation

#ifndef SHERPA_ONNX_PYTHON_CSRC_SPEAKER_EMBEDDING_MANAGER_H_
#define SHERPA_ONNX_PYTHON_CSRC_SPEAKER_EMBEDDING_MANAGER_H_

#include "sherpa-onnx/python/csrc/sherpa-onnx.h"

namespace sherpa_onnx {

void PybindSpeakerEmbeddingManager(py::module *m);

}  // namespace sherpa_onnx

#endif  // SHERPA_ONNX_PYTHON_CSRC_SPEAKER_EMBEDDING_MANAGER_H_
