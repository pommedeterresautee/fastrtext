// [[Rcpp::plugins(cpp11)]]

#include <Rcpp.h>
#include <iostream>
#include <sstream>
#include "../inst/include/fasttext.h"
#include "../inst/include/args.h"
#include "../inst/include/main.h"
#include "fasttext_wrapper.h"

using namespace Rcpp;
using namespace fasttext;
using namespace FastTextWrapper;

class FastRText{
public:

  FastRText(): model_loaded(false){
    model =  std::unique_ptr<FastText>(new FastText());
    // HACK: A trick to get access to FastText's private members.
    // Reference: http://stackoverflow.com/a/8282638
    privateMembers = (FastTextPrivateMembers*) model.get();
  }

  ~FastRText(){
    privateMembers->args_.reset();
    privateMembers->dict_.reset();
    privateMembers->input_.reset();
    privateMembers->output_.reset();
    privateMembers->model_.reset();
    model.reset();
  }

  void load(CharacterVector path) {
    if(path.size() != 1){
      stop("You have provided " + std::to_string(path.size()) + " paths instead of one.");
    }
    if(!std::ifstream(path[0])){
      stop("Path doesn't point to a file: " + path[0]);
    }
    model.reset(new FastText);
    privateMembers = (FastTextPrivateMembers*) model.get();
    std::string stringPath(path(0));
    model->loadModel(stringPath);
    model_loaded = true;
  }

  void load_model(const std::string& filename) {
    model->loadModel(filename);
  }

  void execute(CharacterVector commands) {
    int num_argc = commands.size();

    if (num_argc < 2) {
      stop("Not enough parameters");
      return;
    }

    char** cstrings = new char*[commands.size()];
    for(size_t i = 0; i < commands.size(); ++i) {
      std::string command(commands[i]);
      cstrings[i] = new char[command.size() + 1];
      std::strcpy(cstrings[i], command.c_str());
    }
    Rcout << "Just before main" << std::endl;
    main(num_argc, cstrings);
    for(size_t i = 0; i < num_argc; ++i) {
      delete[] cstrings[i];
    }
    delete[] cstrings;
  }

  List predict(CharacterVector documents, int k = 1) {
    check_model_loaded();
    List list(documents.size());

    for(int i = 0; i < documents.size(); ++i){
      std::string s(documents(i));
      std::vector<std::pair<real, std::string> > predictions = predict_proba(s, k);
      NumericVector logProbabilities(predictions.size());
      CharacterVector labels(predictions.size());
      for (int j = 0; j < predictions.size() ; ++j){
        logProbabilities[j] = predictions[j].first;
        labels[j] = predictions[j].second;
      }
      NumericVector probabilities(exp(logProbabilities));
      probabilities.attr("names") = labels;
      list[i] = probabilities;
    }
    return list;
  }

  List get_parameters(){
    check_model_loaded();
    double learning_rate(privateMembers->args_->lr);
    int learning_rate_update(privateMembers->args_->lrUpdateRate);
    int dim(privateMembers->args_->dim);
    int context_window_size(privateMembers->args_->ws);
    int epoch(privateMembers->args_->epoch);
    int min_count(privateMembers->args_->minCount);
    int min_count_label(privateMembers->args_->minCountLabel);
    int n_sampled_negatives(privateMembers->args_->neg);
    int word_ngram(privateMembers->args_->wordNgrams);
    int bucket(privateMembers->args_->bucket);
    int min_ngram(privateMembers->args_->minn);
    int max_ngram(privateMembers->args_->maxn);
    double sampling_threshold(privateMembers->args_->t);
    std::string label_prefix(privateMembers->args_->label);
    std::string pretrained_vectors_filename(privateMembers->args_->pretrainedVectors);
    int32_t nlabels(privateMembers->dict_->nlabels());
    int32_t n_words(privateMembers->dict_->nwords());


    return Rcpp::List::create(Rcpp::Named("learning_rate") = wrap(learning_rate),
                              Rcpp::Named("learning_rate_update") = wrap(learning_rate_update),
                              Rcpp::Named("dim") = wrap(dim),
                              Rcpp::Named("context_window_size") = wrap(context_window_size),
                              Rcpp::Named("epoch") = wrap(epoch),
                              Rcpp::Named("min_count") = wrap(min_count),
                              Rcpp::Named("min_count_label") = wrap(min_count_label),
                              Rcpp::Named("n_sampled_negatives") = wrap(n_sampled_negatives),
                              Rcpp::Named("word_ngram") = wrap(word_ngram),
                              Rcpp::Named("bucket") = wrap(bucket),
                              Rcpp::Named("min_ngram") = wrap(min_ngram),
                              Rcpp::Named("max_ngram") = wrap(max_ngram),
                              Rcpp::Named("sampling_threshold") = wrap(sampling_threshold),
                              Rcpp::Named("label_prefix") = wrap(label_prefix),
                              Rcpp::Named("pretrained_vectors_filename") = wrap(pretrained_vectors_filename),
                              Rcpp::Named("nlabels") = wrap(nlabels),
                              Rcpp::Named("n_words") = wrap(n_words),
                              Rcpp::Named("loss_name") = wrap(getLossName()),
                              Rcpp::Named("model_name") = wrap(getModelName()));
  }

  std::vector<std::string> get_words() {
    check_model_loaded();
    std::vector<std::string> words;
    int32_t nwords = privateMembers->dict_->nwords();
    for (int32_t i = 0; i < nwords; i++) {
      words.push_back(getWord(i));
    }
    return words;
  }

  List get_vectors(CharacterVector words){
    check_model_loaded();
    List l(words.size());
    CharacterVector names(words.size());
    for(int i = 0 ; i < words.size(); ++i) {
      std::string word(words(i));
      NumericVector vector = get_vector(word);
      l[i] = vector;
      names[i] = word;
    }
    l.attr("names") = names;
    return l;
  }

  std::vector<std::string> get_labels() {
    check_model_loaded();
    std::vector<std::string> labels;
    int32_t nlabels = privateMembers->dict_->nlabels();
    for (int32_t i = 0; i < nlabels; i++) {
      labels.push_back(getLabel(i));
    }
    return labels;
  }

  void test(const std::string& filename, int32_t k) {
    std::ifstream ifs(filename);
    if(!ifs.is_open()) {
      stop("Test file cannot be opened!");
    }
    model->test(ifs, k);
  }

  std::vector<std::pair<real,std::string> > predict_proba(
      const std::string& text, int32_t k) {
    std::vector<std::pair<real,std::string> > predictions;
    std::istringstream in(text);
    model->predict(in, k, predictions);
    return predictions;
  }

  void print_help(){
    std::shared_ptr<Args> a = std::make_shared<Args>();
    a->printHelp();
  }

private:
  FastTextPrivateMembers* privateMembers;
  std::unique_ptr<FastText> model;
  bool model_loaded;

  void check_model_loaded(){
    if(!model_loaded){
      stop("This model has not yet been loaded.");
    }
  }

  std::string getWord(int32_t i) {
    return privateMembers->dict_->getWord(i);
  }

  NumericVector get_vector(const std::string& word) {
    fasttext::Vector vec(privateMembers->args_->dim);
    model->getVector(vec, word);
    return wrap(std::vector<real>(vec.data_, vec.data_ + vec.m_));
  }

  std::string getLabel(int32_t i) {
    return privateMembers->dict_->getLabel(i);
  }

  std::string getLossName() {
    loss_name lossName = privateMembers->args_->loss;
    if (lossName == loss_name::ns) {
      return "ns";
    } else if (lossName == loss_name::hs) {
      return "hs";
    } else if (lossName == loss_name::softmax) {
      return "softmax";
    } else {
      stop("Unrecognized loss (ns / hs / softmax) name!");
    }
  }

  std::string getModelName() {
    model_name modelName = privateMembers->args_->model;
    if (modelName == model_name::cbow) {
      return "cbow";
    } else if (modelName == model_name::sg) {
      return "sg";
    } else if (modelName == model_name::sup) {
      return "supervised";
    } else {
      stop("Unrecognized model (cbow / SG / supervised) name!");
    }
  }
};


RCPP_MODULE(FASTRTEXT_MODULE) {
  class_<FastRText>("FastRText")
  .constructor("Managed fasttext model")
  .method("load", &FastRText::load, "Load a model")
  .method("predict", &FastRText::predict, "Make a prediction")
  .method("execute", &FastRText::execute, "Execute commands")
  .method("get_vectors", &FastRText::get_vectors, "Get vectors related to provided words")
  .method("get_parameters", &FastRText::get_parameters, "Get parameters used to train the model")
  .method("get_words", &FastRText::get_words, "List all words learned")
  .method("get_labels", &FastRText::get_labels, "List all labels")
  .method("print_help", &FastRText::print_help, "Print command helps");
}
