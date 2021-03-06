#include <stdio.h>
#include <stdlib.h>

#include "llamapun/unicode_normalizer.h"
#include "llamapun/tokenizer.h"

#include <libxml/parser.h>
#include <libxml/tree.h>

int main(void) {
  //load example document
  fprintf(stderr, "\n\n Tokenization tests\n\n");
  initialize_tokenizer("../../third-party/senna/");

  xmlDocPtr doc = xmlReadFile("../../t/documents/1311.0066.xhtml", NULL, XML_PARSE_RECOVER | XML_PARSE_NONET);
  if (doc == NULL) { return 1;}
  unicode_normalize_dom(doc);
  //Create DNM, with normalized math tags, and ignoring cite tags
  dnmPtr mydnm = create_DNM(xmlDocGetRootElement(doc), DNM_NORMALIZE_TAGS | DNM_IGNORE_LATEX_NOTES);
  if (mydnm == NULL) { return 1;}
  char* text = mydnm->plaintext;
  dnmRanges sentences = tokenize_sentences(text);
  // TODO: We need better tokenization tests, this is a hack...
  if (sentences.length < 730) {   //something could have gone wrong...
    fprintf(stderr, "There were too few sentences tokenized: %d!\n", sentences.length);
    return 1;
  }
  if (sentences.length > 750) {   //something could have gone wrong...
    fprintf(stderr, "There were too many sentences tokenized: %d!\n",sentences.length);
    return 1;
  }

  int sentence_index;
  for (sentence_index=0; sentence_index < sentences.length; sentence_index++) {
    if (sentences.range[sentence_index].end < sentences.range[sentence_index].start) {
      fprintf(stderr, "Invalid sentence, start appears after end!\n");
      return 1;
    }
    dnmRanges words = tokenize_words(text, sentences.range[sentence_index], TOKENIZER_ACCEPT_ALL);
//    fprintf(stderr,"=====\n");
//    fprintf(stderr,"%.*s\n",(sentences.range[sentence_index].end-sentences.range[sentence_index].start+1),(text+sentences.range[sentence_index].start));
//    fprintf(stderr,"-----\n");
//    display_ranges(words, mydnm->plaintext);
    if (words.length == 0) {
        fprintf(stderr, "Sentence had no words tokenized, aborting.\n");
        return 1;
    }
    free(words.range);
  }

  //clean up
  free_tokenizer();
  free(sentences.range);
  free_DNM(mydnm);
  xmlFreeDoc(doc);
  xmlCleanupParser();

  return 0;
}
