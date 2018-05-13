#!/usr/bin/python
# -*- coding: utf-8 -*-
##############################################################################################
# Copyright (c) by Mario Frasca (2018)
# License:     GPL3
##############################################################################################


import sys
from PySide.QtCore import *
from PySide.QtGui import *
from PySide.QtDeclarative import *
from PySide.QtGui import QDesktopServices as QDS

import math
import platform
import os
import json


from datetime import tzinfo, timedelta, datetime
import logging
logger = logging.getLogger(__name__)

PROGRAM_NAME = "taxonomic-help"

class RpnApp(QApplication):
    "Reverse Polish Notation class"

    root = "/opt/taxonomy-helper/"
    version = "??"
    build = "?"

    def __init__(self, argv):
        super(RpnApp, self).__init__(argv)
        logging.basicConfig()
        
        if(platform.machine().startswith('arm')):
            pass
        else:
            self.root = "./"
            self.path = "./data/"
        try:
            os.makedirs(self.path)
        except:
            pass
        
        try:
            versionfilename = os.path.join(self.root, "version")
            with open(versionfilename, 'r') as file:
                self.version = file.readline().strip()
                self.build = file.readline().strip()
                logger.info("Version: %s-%s" % (self.version, self.build))
        except Exception, e:
            logger.error("%s(%s) reading version file %s." % (type(e), e, versionfilename))

        self.config = Configuration()

    def finished(self):
        self.config.values = {}
        self.config.write()
        logger.debug("Closed")

    @Slot(result=str)
    def get_version(self):
        return str(self.version) + "-" + str(self.build)

    def make_phonetic(self, term):
        import re
        epithet = term.lower();  # ignore case
        epithet = epithet.replace("-", "");  # remove hyphen
        epithet = re.sub("c+([yie])", "z\\1", epithet);  # palatal c sounds like z
        epithet = re.sub("g([ie])", "j\\1", epithet);  # palatal g sounds like j
        epithet = re.sub("ph", "f", epithet);  # ph sounds like f
        epithet = epithet.replace("v", "f");  # v sounds like f # fricative (voiced or not)

        epithet = epithet.replace("h", "");  # h sounds like nothing
        epithet = re.sub("[gcq]", "k", epithet);  # g, c, q sound like k # guttural
        epithet = re.sub("[xz]", "s", epithet);  # x, z sound like s
        epithet = epithet.replace("ae", "e");  # ae sounds like e
        epithet = re.sub("[ye]", "i", epithet);  # y, e sound like i
        epithet = re.sub("[ou]", "u", epithet);  # o, u sound like u # so we only have a, i, u
        epithet = re.sub("[aiu]([aiu])[aiu]*", "\\1", epithet);  # remove diphtongs
        epithet = re.sub("(.)\\1", "\\1", epithet);  # doubled letters sound like single
        return epithet
        
    
    @Slot(str, bool, result=str)
    def get_taxonomic_derivation(self, search_term, phonetic):
        import sqlite3

        cn = sqlite3.connect("/opt/taxonomy-helper/assets/taxonomy.db")
        cr = cn.cursor()
        if phonetic:
            search_term = self.make_phonetic(search_term)
            search_column = 'metaphone'
        else:
            search_column = 'epithet'
        print search_column, search_term

        cr.execute("select epithet, authorship, accepted_id, parent_id from taxon "
                   "where rank=5 and %s like '%s%%' "
                   "order by epithet" %
                   (search_column, search_term))

        rankname = {0: 'ordo', 1: 'familia', 2: 'subfamilia', 3: 'tribus', 4: 'subtribus', 5: 'genus'}

        result = []

        for epithet, authorship, accepted_id, parent_id in cr.fetchall():
            format = "%s, %s"
            if accepted_id:
                parent_id = accepted_id
                format = "(%s, %s)"
            result.append(format % (epithet, authorship or ''))
            while parent_id:
                cr.execute("select epithet, authorship, accepted_id, parent_id from taxon where id=%s" % parent_id)
                epithet, authorship, accepted_id, parent_id = cr.fetchone()
                format = "%s, %s"
                if accepted_id:
                    parent_id = accepted_id
                    format = "(%s, %s)"
                result.append(format % (epithet, authorship or ''))

            result.append(u'————————')

        return json.dumps(result)
        

####################################################################################################
class Configuration():

    def __init__(self):
        self.configpath = os.path.join(QDS.storageLocation(QDS.DataLocation), PROGRAM_NAME)
        self.configfile = os.path.join(self.configpath, "config.json")

        logger.debug("Loading configuration from: %s" % self.configfile)
        try:
            with open(self.configfile, 'r') as handle:
                self.values = json.load(handle)
            logger.debug("Configuration loaded")
        except:
            logger.error("Failed to load configuration file!")
            self.values = {}

    def write(self):
        logger.debug("Write configuration to: %s" % self.configfile)

        try:
            os.makedirs(self.configpath)
        except:
            pass

        try:
            with open(self.configfile, 'w') as handle:
                json.dump(self.values, handle)
            logger.debug("Configuration saved")
        except Exception, e:
            logger.error("%s(%s) writing configuration file!" % (type(e), e))



################################################################################################
if __name__ == '__main__':
    this_app = RpnApp(sys.argv)
    logging.basicConfig(stream=sys.stderr, level=logging.WARNING)

    view = QDeclarativeView()
    context = view.rootContext()
    context.setContextProperty("app", this_app)
    view.setSource(QUrl.fromLocalFile(this_app.root + 'qml/main.qml'))

    if(platform.machine().startswith('arm')):
        view.showFullScreen()
        view.show()

    this_app.exec_()  # endless loop
    this_app.finished()
