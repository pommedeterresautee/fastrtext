#ifndef FASTTEXT_WRAPPER_H
#define FASTTEXT_WRAPPER_H

#include "fasttext/args.h"
#include "fasttext/dictionary.h"
#include "fasttext/matrix.h"
#include "fasttext/model.h"

/**
 * FastText's wrapper misc
 */
namespace FastTextWrapper {

struct FastTextPrivateMembers {
  std::shared_ptr <fasttext::Args> args_;
  std::shared_ptr <fasttext::Dictionary> dict_;
  std::shared_ptr <fasttext::Matrix> input_;
  std::shared_ptr <fasttext::Matrix> output_;
  std::shared_ptr <fasttext::Model> model_;
};
}

#endif // FASTTEXT_WRAPPER_H
