#!/usr/bin/env python3
#^^^^ <--> Nomadnet specific to prevent page caching, may change if you like.

import urllib.parse
import ignition
import textwrap
import time
import yaml
from os import environ
import os
page = []
redirect = ""
backlink = ""
backurl = ""
#with open("settings.yaml", "r") as file:
#    settings = yaml.safe_load(file)
#MYNODE = settings.get("MYNODE")        #config who's to listen
#USERS = settings.get("USERS")          # List of users

def onReceive(message):

    global redirect
    emptyline = ""
    iline = ""
    redirect = ""
    try:
            #message_parts = message.split(" ")
            reloadline = ""
            if message[:9] == "gemini://" :
                url = message[9:]
            else :
                url = message
            master_path = ""
            master_spath = ""
            response = ignition.request("gemini://"+url)
            parsed =  urllib.parse.urlparse("gemini://"+url)

            master_scheme = parsed.scheme
            master_netloc = parsed.netloc
            master_spath1 = parsed.path
            master_spath = master_spath1.split("/" or "\r")
            #print (master_spath)
            for  spath in master_spath :
                if ".gmi" not in spath and spath != "" and ".gemini" not in spath:
                    master_path = master_path +"/" + spath 
                    print (master_path)
 
            #master_path = parsed.path
            
            master_query = parsed.query
            home = master_netloc
            print ("`B595 `!`["+master_netloc+"`:/page/rgproxy.mu`resultat="+master_netloc+"]`b`` "+url)
            print ("---")
            if response.is_a(ignition.SuccessResponse):
                text = (response.data())
                tosend = text.split("\n")
                for index, line in enumerate(tosend):

                    #line = line.replace("`","'")
                    if line[:3] == "```" :
                         line = "`="
                        
                    elif line[:3] == "###" :
                         line = ">>>"+line[3:]
                    elif line[:2] == "##" :
                        line = ">>"+line[2:]
                    elif line[:1] == "#" :
                        line = ">"+line[1:]
                    elif line[:2] == "=>":
                        line = line.replace("`","'")

                        line = line[2:].lstrip(" ")

                        line_part = line.split(" ",maxsplit=1)
                        requested_url = line_part[0]
                        if len(line_part) ==1 :
                            showlink = line_part[0]
                        else :
                            showlink = line_part[1]
                        #print (requested_url)

                        #if "://" not in requested_url:
                        #    requested_url = "gemini://" + requested_url
                        parsed =  urllib.parse.urlparse(requested_url)
                        #print ("==="+showlink)
                        request_scheme = parsed.scheme
                        request_netloc = parsed.netloc
                        request_path = parsed.path
                        request_query = parsed.query
                        if request_scheme =="gemini" or request_scheme =="" :
                            #print (parsed)
                            #print (line)


                            if request_path[:2] == "//" :
                                request_netloc = request_path[1:]
                                request_path = "" 
                            if "gmi" in request_netloc or "py" in request_netloc or "txt" in request_netloc or "md" in request_netloc:
                                if "gmi" in request_path :
                                    request_netloc = master_netloc
                                else :
                                    request_path = "/"+request_netloc.lstrip("/")
                                    request_netloc = ""
                            elif "gmi" in request_path :
                                findit = request_path.find(".gmi")+4
                                if findit < len(request_path) :
                                   #print (len(request_path)-findit)
                                   request_path = request_path[:-(len(request_path)-findit)]
                            if request_path[:2] ==".." :
                                request_path = request_path[2:]
                                request_netloc = ".."
                            if request_path[:1] =="." :
                                request_path = request_path[1:]
                                request_netloc = "."
                            if request_path[:1] !="/" :
                               symbol ="/"
                            else :
                               symbol = ""
                               if request_netloc =="":
                                   request_netloc=".."
                            if request_query !="" :
                               symbol2 ="?"
                            else :
                               symbol2 = ""
 
                            if request_netloc =="..":
                                line = "`F089`["+showlink+"`:/page/rgproxy.mu`resultat="+home.rstrip("/")+symbol+request_path+symbol2+request_query+"|backurl="+url+"]`f``"
                            elif request_netloc =="." or (symbol =="/" and request_netloc==""):
                                line = "`F039`["+showlink+"`:/page/rgproxy.mu`resultat="+home.rstrip("/")+master_path+symbol+request_path+symbol2+request_query+"|backurl="+url+"]`f``"
                            elif request_netloc ==""  :
                                line = "`F039`["+showlink+"`:/page/rgproxy.mu`resultat="+home.rstrip("/")+master_path+symbol+request_path+symbol2+request_query+"|backurl="+url+"]`f``"
                            else :
                                line = "`F099`["+showlink+"`:/page/rgproxy.mu`resultat="+request_netloc+symbol+request_path+symbol2+request_query+"|backurl="+url+"]`f``"
                            #print (line_part[0])
                        else :
                            line = "`F669 Unusable link `f "

                    else :
                        line = line.replace("`","'")
                    print (line)


            elif response.is_a(ignition.InputResponse):
                print ("Needs additional input: ")
                print ()
                print (f'{response.data()} `B444`<30|user_input`>`b  `!`B500`[Submit`:/page/rgproxy.mu`resultat='+url+'|user_input]`b')

            elif response.is_a(ignition.RedirectResponse):
                print(f"Received response, redirect to: {response.data()}")
                if response.data()[:9] == "gemini://":
                    redirect = response.data()

                else :
                    hurl = url.split("/")
                    home = hurl[0]
                    print(home)
                    redirect = home+response.data()
                print (redirect)
            elif response.is_a(ignition.TempFailureResponse):
                print(f"Error from server: {response.data()}")

            elif response.is_a(ignition.PermFailureResponse):
                print(f"Error from server: {response.data()}")

            elif response.is_a(ignition.ClientCertRequiredResponse):
                print(f"Client certificate required. {response.data()}")

            elif response.is_a(ignition.ErrorResponse):
                print(f"There was an error on the request: {response.data()}")
    except KeyError as e:
        print(f"Error processing packet: {e}")

if environ.get("var_backurl") != None :
    backurl =  str(environ.get("var_backurl"))

print ("> Gemini Proxy          `F919 Beta Version, under construction no certificate and somes bugs`f")
#print (" `F919 Beta Version, under construction`f")
print ("")
print ('Input gemini link or search term `B500gemini://`B444`<30|user_input`>`b  `!`B500`[Go to link`:/page/rgproxy.mu`user_input]`b or `!`B505`[Search`:/page/rgproxy.mu`resultat=kennedy.gemi.dev/search|user_input]`b')
print ("")
print ("`B559`!`[Main menu`:/page/index.mu]`b `B329`!`[Proxy Menu`:/page/rgproxy.mu`resultat=]`b  `B128`!`[Search Engine`:/page/rgproxy.mu`resultat=kennedy.gemi.dev]`b  `B659`!`[Back`:/page/rgproxy.mu`resultat="+backurl+"]`b")
print ("")

if environ.get("field_user_input") != None and environ.get("var_resultat") != None:
        os.environ['var_resultat'] =  environ.get("var_resultat")+"?"+environ.get("field_user_input")


if environ.get("field_user_input") != None and environ.get("var_resultat") == None:
        os.environ['var_resultat'] =  environ.get("field_user_input")

if   environ.get("var_resultat") == None or environ.get("var_resultat") == "":
        #print (os.environ)    
        #print (environ.get("var_resultat"))
        print ('>> Bookmarks')
        print ("")
        print ("")
        print  ('`!`[Gemi.dev`:/page/rgproxy.mu`resultat=gemi.dev]')
        print ("")
        print  ('`!`[Techrights`:/page/rgproxy.mu`resultat=gemini.techrights.org]')
        print ("")
        print  ('`!`[GeminiSpace`:/page/rgproxy.mu`resultat=bbs.geminispace.org]')
        print ("")
        print  ('`!`[Tilde.team`:/page/rgproxy.mu`resultat=tilde.team/]')
        print ("")
        print  ('`!`[mozz.us`:/page/rgproxy.mu`resultat=mozz.us]')
        print ("")
        print  ('`!`[Yesterweb`:/page/rgproxy.mu`resultat=cities.yesterweb.org]')
        print ("")
        print  ('`!`[Hyperreal`:/page/rgproxy.mu`resultat=hyperreal.coffee]')
        print ("")
        print  ('`!`[My Plant at Astrobotany`:/page/rgproxy.mu`resultat=astrobotany.mozz.us/public/d21632c653e546f2aa6a620b848839b9]')
        print ("")
        print (">> Games")
        print ("")
        print ("")
        print  ('`!`[Underground Kingdom`:/page/rgproxy.mu`resultat=typed-hole.org/cyoa/underground]')
        print ("")
        print  ('`!`[Secret of Pyramids`:/page/rgproxy.mu`resultat=typed-hole.org/cyoa2/pyramid.gemini]')


else :
        #print (environ.get("var_resultat"))
        onReceive(environ.get("var_resultat"))
        print (redirect)
        if redirect !="" :
            onReceive(redirect)
            print ("ca marche redirect "+redirect)

        print ("you're on "+environ.get("var_resultat"))
