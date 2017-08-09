#include <iostream>
#include <sstream>

#include "fasttext_wrapper.h"
#include "main.h"

/**
* FastText's wrapper
*/
namespace FastTextWrapper {

using namespace fasttext;

FastTextApi::FastTextApi() {
  // HACK: A trick to get access to FastText's private members.
  // Reference: http://stackoverflow.com/a/8282638
  privateMembers = (FastTextPrivateMembers*) &fastText;
}

void FastTextApi::runCmd(int argc, char **argv) {
  main(argc, argv);  // call fastText's main()
}

void FastTextApi::loadModel(const std::string& filename) {
  fastText.loadModel(filename);
}


void FastTextApi::test(const std::string& filename, int32_t k) {
  std::ifstream ifs(filename);
  if(!ifs.is_open()) {
    std::cerr << "fasttest_wrapper.cc: Test file cannot be opened!" << std::endl;
    exit(EXIT_FAILURE);
  }
  fastText.test(ifs, k);
}

std::vector<std::string> FastTextApi::predict(const std::string& text, int32_t k) {
  std::vector<std::pair<real,std::string>> predictions = predictProba(text, k);
  std::vector<std::string> labels;
  for (auto it = predictions.cbegin(); it != predictions.cend(); ++it) {
    labels.push_back(it->second);
  }
  return labels;
}

std::vector<std::pair<real,std::string>> FastTextApi::predictProba(
    const std::string& text, int32_t k) {
  std::vector<std::pair<real,std::string>> predictions;
  std::istringstream in(text);
  fastText.predict(in, k, predictions);
  return predictions;
}

std::vector<real> FastTextApi::getVector(const std::string& word) {
  Vector vec(privateMembers->args_->dim);
  fastText.getVector(vec, word);
  return std::vector<real>(vec.data_, vec.data_ + vec.m_);
}
}
