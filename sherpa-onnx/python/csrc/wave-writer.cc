// sherpa-onnx/python/csrc/wave-writer.cc
//
// Copyright (c)  2024  Xiaomi Corporation

#include "sherpa-onnx/python/csrc/wave-writer.h"

#include <string>
#include <vector>

#include "sherpa-onnx/csrc/wave-writer.h"

namespace sherpa_onnx {

void PybindWaveWriter(py::module *m) {
  m->def(
      "write_wave",
      [](const std::string &filename, const std::vector<float> &samples,
         int32_t sample_rate) -> bool {
        bool ok =
            WriteWave(filename, sample_rate, samples.data(), samples.size());

        return ok;
      },
      py::arg("filename"), py::arg("samples"), py::arg("sample_rate"));
}

}  // namespace sherpa_onnx
