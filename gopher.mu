#!/usr/bin/env python3
#^^^^ <--> Nomadnet specific to prevent page caching, may change if you like.

import urllib.parse
import textwrap
import time
from os import environ
import os
import pituophis

backurl = ""
def onReceive(message):
    type = "1"
    #results = pituophis.get(message).text()
    #print(results)
    #print ("1 "+message)
    message = message.replace("^",":")

    #print ("2 "+message)

    parse = message.split("/")
    host = parse[0]
    if len(parse) >1 :
        if len(parse[1]) > 1 :
            type = parse[1][:1]
        else :
            type = parse[1]

    print (type)
    print ("`B595 `!`["+host+"`:/page/gopher.mu`resultat="+host+"]`b`  "+message)
    print ("---")
    if type == '0' or type =='3':
        content  = pituophis.get("gopher://"+message).text()
        content = content.replace("\t","        ")
        content = content.replace("\r","")
        content = content.replace("`",chr(39))
        print ("`=")
        print (content)
        print ("`=")

    else :
        menu = pituophis.get("gopher://"+message).menu()
        for item in menu:
            if item.port !="" :
                #port = ""
                port ="^"+str(item.port)
            else :
                port = ""
            url = item.host+port+'/'+item.type+item.path
            url = url.replace("?","%09")
            #print(item.type)
            if item.type == '0':
                print('`B217`!`['+item.text+'`:/page/gopher.mu`resultat='+url+'|backurl='+message+']`b')
            elif item.type == '1':
                print('`B166`!`['+item.text+'`:/page/gopher.mu`resultat='+url+'|backurl='+message+']`b')
            elif item.type == '7' :
                print(item.text)
                print("")
                print('`B444`<30|user_input`>`b  `!`B605`[Submit`:/page/gopher.mu`resultat='+url+'|user_input]`b')
            else :
                content = item.text.replace("\t","    ")
                content = content.replace("\r","")
                content = content.replace("\n","")
                content = content.replace("`",chr(39))
                content = content.replace(chr(34),chr(39))
                #content = content.replace("\92","\92\92")
                #content = ascii(content)
                print ("`=")
                #print (content[1:-1])
                print(content)
                print ("`=")

           #print(item.path)
           #print(item.host)
           #print(item.port)

if environ.get("var_backurl") != None :
    backurl =  str(environ.get("var_backurl"))

print ("> Gopher Proxy          `F919 Beta Version, under construction`f")
print ("")
print ('Input Gopher link `B500gopher://`B444`<30|user_input`>`b  `!`B500`[Go to link`:/page/gopher.mu`user_input]`b')
print ("")
#print ("`B559`!`[Main menu`:/page/index.mu]`b `B329`!`[Proxy Menu`:/page/gopher.mu`resultat=]`b" )
print ("`B559`!`[Main menu`:/page/index.mu]`b `B329`!`[Proxy Menu`:/page/gopher.mu`resultat=]`b  `B128`!`[Search Engine`:/page/gopher.mu`resultat=gopher.floodgap.com/1/v2/]`b  `B659`!`[Back`:/page/gopher.mu`resultat="+backurl+"]`b")
print ("")

if environ.get("field_user_input") != None and environ.get("var_resultat") != None:
        os.environ['var_resultat'] =  environ.get("var_resultat")+"%09"+environ.get("field_user_input")


if environ.get("field_user_input") != None and environ.get("var_resultat") == None:
        os.environ['var_resultat'] =  environ.get("field_user_input")

if   environ.get("var_resultat") == None or environ.get("var_resultat") == "":
      
        print ('>> Bookmarks')
        print ("")
        print ('`!`[Mozz.us`:/page/gopher.mu`resultat=mozz.us]')
        print ("")
        print ('`!`[1436.ninja`:/page/gopher.mu`resultat=1436.ninja]')
        print ("")
        print ('`!`[Infinitely Remote`:/page/gopher.mu`resultat=infinitelyremote.com]')
        print ("")
        print ('`!`[Floodgap`:/page/gopher.mu`resultat=gopher.floodgap.com]')
        print ("")


else :
        url = environ.get("var_resultat")
        urlcorrect=url.replace(":","^")
        onReceive(urlcorrect)

        print ("you're on "+url)
