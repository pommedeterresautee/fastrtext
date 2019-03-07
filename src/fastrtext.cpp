// [[Rcpp::plugins(cpp11)]]

#include <Rcpp.h>
#include <iostream>
#include <sstream>
#include <queue>
#include "fasttext/fasttext.h"
#include "fasttext/args.h"
#include "main.h"

using namespace Rcpp;
using namespace fasttext;

class fastrtext{
public:

  fastrtext(): model_loaded(false){
    model =  std::unique_ptr<FastText>(new FastText());
  }

  ~fastrtext(){
    model.reset();
  }

  void load(const std::string path) {
    if(!std::ifstream(path)){
      stop("Path doesn't point to a file: " + path);
    }
    model.reset(new FastText);
    model->loadModel(path);
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
    std::string command;
    for(size_t i = 0; i < commands.size(); ++i) {
      command = commands[i];
      cstrings[i] = new char[command.size() + 1];
      std::strcpy(cstrings[i], command.c_str());
    }
    main(num_argc, cstrings);
    for(size_t i = 0; i < num_argc; ++i) {
      delete[] cstrings[i];
    }
    delete[] cstrings;
    std::Rcout << "" << std::endl;
  }

  List predict(CharacterVector documents, int k = 1, real threshold = 0) {
    check_model_loaded();
    List list(documents.size());
    int label_prefix_size = model->getArgs().label.size();
    std::string s;
    for (int i = 0; i < documents.size(); ++i){
      s = documents[i];
      auto predictions = predict_proba(s, k, threshold);
      NumericVector logProbabilities(predictions.size());
      CharacterVector labels(predictions.size());
      for (size_t j = 0; j < predictions.size() ; ++j){
        logProbabilities[j] = predictions[j].first;
        // remove label prefix
        std::string label_without_prefix = predictions[j].second.erase(0, label_prefix_size);
        labels[j] = label_without_prefix;
      }
      NumericVector probabilities(exp(logProbabilities));
      probabilities.attr("names") = labels;
      list[i] = probabilities;
      if (i % 5 == 0) Rcpp::checkUserInterrupt();
    }
    return list;
  }

  List get_parameters(){
    check_model_loaded();
    double learning_rate(model->getArgs().lr);
    int learning_rate_update(model->getArgs().lrUpdateRate);
    int dim(model->getDimension());
    int context_window_size(model->getArgs().ws);
    int epoch(model->getArgs().epoch);
    int min_count(model->getArgs().minCount);
    int min_count_label(model->getArgs().minCountLabel);
    int n_sampled_negatives(model->getArgs().neg);
    int word_ngram(model->getArgs().wordNgrams);
    int bucket(model->getArgs().bucket);
    int min_ngram(model->getArgs().minn);
    int max_ngram(model->getArgs().maxn);
    double sampling_threshold(model->getArgs().t);
    std::string label_prefix(model->getArgs().label);
    std::string pretrained_vectors_filename(model->getArgs().pretrainedVectors);
    int32_t nlabels(model->getDictionary()->nlabels());
    int32_t n_words(model->getDictionary()->nwords());


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

  std::vector<std::string> get_dictionary() {
    check_model_loaded();
    std::vector<std::string> words;
    int32_t nwords = model->getDictionary()->nwords();
    for (int32_t i = 0; i < nwords; i++) {
      words.push_back(getWord(i));
    }
    return words;
  }

  NumericVector get_vector(const std::string& word) {
    check_model_loaded();
    fasttext::Vector vec(model->getDimension());
    model->getWordVector(vec, word);
    return wrap(std::vector<real>(vec.data(), vec.data() + vec.size()));
  }

  NumericMatrix get_vectors(CharacterVector words){
    check_model_loaded();
    int dim(model->getDimension());
    NumericMatrix mat(words.size(), dim);
    CharacterVector names(words.size());

    for(int i = 0 ; i < words.size(); ++i) {
      std::string word(words(i));
      names[i] = word;
      mat.row(i) = get_vector(word);
      Rcpp::checkUserInterrupt();
    }

    rownames(mat) = names;
    return mat;
  }

  NumericVector get_word_ids(CharacterVector words) {
    check_model_loaded();
    NumericVector ids(words.size());
    std::string s;
    for (int i = 0 ; i < words.size(); ++i) {
      s = words[i];
      ids[i] = model->getWordId(s) + 1;
    }
    return ids;
  }

  std::vector<std::string> get_labels() {
    check_model_loaded();
    std::vector<std::string> labels;
    int32_t nlabels = model->getDictionary()->nlabels();
    for (int32_t i = 0; i < nlabels; i++) {
      labels.push_back(getLabel(i));
      Rcpp::checkUserInterrupt();
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

  std::vector<std::pair<real,std::string> > predict_proba(const std::string& text, int32_t k, real threshold) {
    std::vector<std::pair<real,std::string> > predictions;
    std::istringstream in(text);
    model->predictLine(in, predictions, k, threshold);
    return predictions;
  }

  NumericVector get_nn_by_word(const std::string& queryWord, int32_t k) {
    std::vector<std::pair<real, std::string>> results = model->getNN(queryWord, k);

    NumericVector distances(k);
    CharacterVector word_string(k);
    int32_t i = 0;

    for (int i = 0; i < results.size(); ++i) {
      distances[i] = results[i].first;
      word_string[i] = results[i].second;
      Rcpp::checkUserInterrupt();
    }

    distances.attr("names") = word_string;

    return distances;
  }

  void print_help(){
    std::shared_ptr<Args> a = std::make_shared<Args>();
    a->printHelp();
  }

  CharacterVector tokenize(const std::string text){
    check_model_loaded();
    std::vector<std::string> text_split;
    std::shared_ptr<const fasttext::Dictionary> d = model->getDictionary();
    std::stringstream ioss;
    copy(text.begin(), text.end(), std::ostream_iterator<char>(ioss));
    std::string token;
    while (!ioss.eof()) {
      while (d->readWord(ioss, token)) {
        text_split.push_back(token);
      }
    }
    return wrap(text_split);
  }

  NumericVector get_sentence_embeddings(const CharacterVector& sentences) {
    check_model_loaded();
    int dimensions = model->getDimension();
    NumericMatrix sentence_embeddings(sentences.size(), dimensions);

    fasttext::Vector v(dimensions);
    NumericVector vector_r;
    std::string sentence;
    for (int i = 0; i < sentences.size(); i++) {
      std::stringstream ioss;
      sentence = as<std::string>(sentences[i]);
      copy(sentence.begin(), sentence.end(), std::ostream_iterator<char>(ioss));
      model->getSentenceVector(ioss, v);
      vector_r = wrap(std::vector<real>(v.data(), v.data() + v.size()));
      sentence_embeddings(i, _) = vector_r;
    }

    return sentence_embeddings;
  }

private:
  std::unique_ptr<FastText> model;
  bool model_loaded;

  void check_model_loaded(){
    if(!model_loaded){
      stop("This model has not yet been loaded.");
    }
  }

  std::string getWord(int32_t i) {
    return model->getDictionary()->getWord(i);
  }

  std::string getLabel(int32_t i) {
    return model->getDictionary()->getLabel(i);
  }

  std::string getLossName() {
    loss_name lossName = model->getArgs().loss;
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
    model_name modelName = model->getArgs().model;
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

  std::shared_ptr<fasttext::Matrix> wordVectors;
};

RCPP_MODULE(FASTRTEXT_MODULE) {
  class_<fastrtext>("fastrtext")
  .constructor("Managed fasttext model")
  .method("load", &fastrtext::load, "Load a model")
  .method("predict", &fastrtext::predict, "Make a prediction")
  .method("execute", &fastrtext::execute, "Execute commands")
  .method("get_word_ids", &fastrtext::get_word_ids, "Get ID of of provided words")
  .method("get_vector", &fastrtext::get_vector, "Get vector related to the provided word")
  .method("get_vectors", &fastrtext::get_vectors, "Get vectors related to provided words")
  .method("get_parameters", &fastrtext::get_parameters, "Get parameters used to train the model")
  .method("get_dictionary", &fastrtext::get_dictionary, "List all words learned")
  .method("get_labels", &fastrtext::get_labels, "List all labels")
  .method("get_nn_by_word", &fastrtext::get_nn_by_word, "Get nearest neighbour words, providing a word")
  .method("tokenize", &fastrtext::tokenize, "Tokenize a text in words")
  .method("get_sentence_embeddings", &fastrtext::get_sentence_embeddings, "Get the dense representation of sentences")
  .method("print_help", &fastrtext::print_help, "Print command helps");
}
