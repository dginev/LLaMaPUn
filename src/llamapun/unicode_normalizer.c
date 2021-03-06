#include <iconv.h>
#include <errno.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "unicode_normalizer.h"

#define in_range(x, a, b) (x >= a && x <= b)

void norm_preprocess(char *string) {
  //removes accents from common diacritics
  //REASON: iconv makes e.g. [o umlaut] to ["o]
  char *readindex = string;
  char *writeindex = string;
  while (*readindex) {
    if (*readindex == '\xc3') {
      readindex++;
      //I don't know why, but casting to unsigned char once prevents annoying compiler warning
      if in_range((unsigned char)*readindex, (unsigned char)'\x80', (unsigned char)'\x85') *writeindex = 'A';
      else if in_range(*readindex, '\x88', '\x8b') *writeindex = 'E';
      else if in_range(*readindex, '\x8c', '\x8f') *writeindex = 'I';
      else if (*readindex == '\x91') *writeindex = 'N';
      else if in_range(*readindex, '\x92', '\x96') *writeindex = 'O';
      else if in_range(*readindex, '\x99', '\x9c') *writeindex = 'U';
      else if (*readindex == '\x9d') *writeindex = 'Y';
      else if in_range(*readindex, '\xa0', '\xa5') *writeindex = 'a';
      else if in_range(*readindex, '\xa8', '\xab') *writeindex = 'e';
      else if in_range(*readindex, '\xac', '\xaf') *writeindex = 'i';
      else if (*readindex == '\xb1') *writeindex = 'n';
      else if in_range(*readindex, '\xb2', '\xb6') *writeindex = 'o';
      else if in_range(*readindex, '\xb9', '\xbc') *writeindex = 'u';
      else if (*readindex == '\xbd') *writeindex = 'y';
      else if (*readindex == '\xbf') *writeindex = 'y';
      else {
        *writeindex++ = '\xc3';   //keep it and don't replace \xc3
        *writeindex = *readindex;
      }
      writeindex++;
    } else {
      *writeindex++ = *readindex;
    }
    readindex++;
  }
  *writeindex = '\0';
}

void normalize_unicode(char *input, char **output) {
  if (*input == '\0') {
    *output = (char *) malloc(sizeof(char));
    **output = '\0';
    return;
  }
  iconv_t conv = iconv_open("ASCII//TRANSLIT//IGNORE", "UTF-8");
  if((long long) conv == -1) {
      if (errno == EINVAL) {
          fprintf(stderr, "unicode_normalizer: Error: Conversion is not supported\n");
      } else {
          fprintf(stderr, "unicode_normalizer: Error: Initialization failure!\n");
      }   
  }

  norm_preprocess(input);

  char *tmp = (char *) malloc(sizeof(char) * (strlen(input) * 10 + 10));   //some memory for the conversion

  char *inptr = input;
  char *outptr = tmp;
  size_t inlength = strlen(input);
  size_t outlength = sizeof(char) * (strlen(input) * 10 + 10);

  iconv(conv, &inptr, &inlength, &outptr, &outlength);

  *outptr = '\0';
  *output = strdup(tmp);
  free(tmp);
    
  iconv_close(conv);
}

void unicode_normalize_dom_actual(xmlNode *n) {
  xmlNode *node;
  xmlNode *newnode;
  xmlNode *tmpnode;
  xmlChar *xmlstr;
  char *newstring;
  for (node = n; node; node = node->next) {
    if (xmlStrEqual(node->name, BAD_CAST "text")) {
      xmlstr = xmlNodeGetContent(node);
      normalize_unicode((char *)xmlstr, &newstring);
      tmpnode = xmlNewText(BAD_CAST newstring);
      if (node->next == NULL && node->prev==NULL) {   //for some reason text nodes cannot be added as siblings
        node = node->parent;
        newnode = node->children;
        xmlUnlinkNode(node->children);
        xmlFreeNode(newnode);
        xmlAddChild(node, tmpnode);
        newnode = tmpnode;
      } else {
        newnode = xmlNewNode(NULL, BAD_CAST "span");
        xmlAddChild(newnode, tmpnode);
        xmlAddNextSibling(node, newnode);
        xmlUnlinkNode(node);
        xmlFreeNode(node);
      }
      node = newnode;
      free(newstring);
      xmlFree(xmlstr);
    } else {
      unicode_normalize_dom_actual(node->children);
    }
  }
}


void unicode_normalize_dom(xmlDocPtr doc) {
  unicode_normalize_dom_actual(xmlDocGetRootElement(doc));
}
