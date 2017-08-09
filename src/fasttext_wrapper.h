#ifndef FASTTEXT_WRAPPER_H
#define FASTTEXT_WRAPPER_H

#include "fasttext.h"
#include "fasttext_wrapper_misc.h"

/**
* FastText's wrapper
*/
namespace FastTextWrapper {

using namespace fasttext;

class FastTextApi {
private:
  FastText fastText;
public:
  FastTextApi();
  FastTextPrivateMembers* privateMembers;
  // We don't make runCmd() a static method so that Loader.load() is always be called in FastTextApi().
  void runCmd(int, char **);
  bool checkModel(const std::string&);
  void loadModel(const std::string&);
  void test(const std::string&, int32_t);
  // TODO: Check if model was loaded
  std::vector<std::string> predict(const std::string&, int32_t);
  std::vector<std::pair<real,std::string>> predictProba(const std::string&, int32_t);
  std::vector<real> getVector(const std::string&);
};
}

#endif
