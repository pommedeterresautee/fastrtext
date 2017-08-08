// [[Rcpp::plugins(cpp11)]]

#include <Rcpp.h>
#include "fasttext_wrapper.h"
//#include "main.h"

using namespace Rcpp;
using namespace FastTextWrapper;

class FastRtext{
public:
  ~FastRtext(){
    model->unloadModel();
    model.reset();
  }

  void load(CharacterVector path) {
    if(path.size() != 1){
      stop("You have provided " + std::to_string(path.size()) + " paths instead of one.");
    }
    if(!std::ifstream(path[0])){
      stop("Path doesn't point to a file: " + path[0]);
    }
    model.reset(new FastTextApi);
    std::string stringPath(path(0));
    model->loadModel(stringPath);
    model_loaded = true;
  }

  //' @param commands commands to execute
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

    model->runCmd(num_argc, cstrings);

    for(size_t i = 0; i < num_argc; ++i) {
      delete[] cstrings[i];
    }
    delete[] cstrings;
  }

  List predict(CharacterVector documents, int k = 1) {
    check_model();
    List list(documents.size());

    for(int i = 0; i < documents.size(); ++i){
      std::string s(documents(i));
      std::vector<std::pair<real, std::string> > predictions = model->predictProba(s, k);
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

  NumericVector printVector(std::string word){
    return wrap(model->getVector(word));
  }

private:
  std::shared_ptr<FastTextApi> model;
  bool model_loaded = false;

  void check_model(){
    if(!model_loaded){
      stop("This model has not yet been loaded.");
    }
  }
};

RCPP_MODULE(FastRtext) {
  class_<FastRtext>("FastRtext")
  .constructor()
  .method("load", &FastRtext::load, "Load a model")
  .method("predict", &FastRtext::predict, "Make a prediction")
  .method("execute", &FastRtext::execute, "Execute commands")
  .method("printVector", &FastRtext::printVector, "Get word vector");

}

/*** R
model <- new(FastRtext)
model$execute(c("f", "supervised"))
model$load("/home/geantvert/model.bin") # requires to have a model there
model$predict(c("this is a test", "another test"), 3)
model$printVector("département")
rm(model)
*/
