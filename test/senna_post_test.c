#define FILENAME_BUFF_SIZE 2048
// Standard C includes
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// JSON
#include <llamapun/json_include.h>
// XML DOM and XPath
#include <libxml/tree.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>

#include <llamapun/senna_pos.h>
#include <llamapun/local_paths.h>

int main() {
  char test_xhtml_doc[FILENAME_BUFF_SIZE];
  sprintf(test_xhtml_doc, "%s/t/documents/1311.6767.xhtml", LLAMAPUN_ROOT_PATH);

  xmlDoc* doc = xmlReadFile(test_xhtml_doc, NULL, 0);
  if (doc == NULL) {
    fprintf(stderr,"Test XHTML document could not be parsed, failing");
    return 1; }
  json_object* response = dom_to_pos_annotations(doc);
  /* Clean up libxml objects */
  xmlFreeDoc(doc);
  xmlCleanupParser();

  int words_total = 0;
  // char *key; struct json_object *val; struct lh_entry *entry;
  // for(entry = json_object_get_object(response)->head; (entry ? (key = (char*)entry->k, val = (struct json_object*)entry->v, entry) : 0); entry = entry->next) {
  //   words_total++;
  // }
  struct lh_entry *entry;
  for(entry = json_object_get_object(response)->head; (entry ? 1 : 0); entry = entry->next) {
    words_total++;
  }

  if (words_total != 6189) {
    fprintf(stderr,"POS tagged words -- count mismatch, got %d \n",words_total);
    return 1;  }

  json_object_put(response);

  // all OK
  return 0;
}
