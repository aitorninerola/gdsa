#!/usr/bin/python
# -*- coding: utf-8 -*-
import MySQLdb as SQL
import numpy as np
import matplotlib.pyplot as pl
import math as m
import glob as g
import sys
import string as s
from StringIO import StringIO
import time

path = "./results/*.txt"
x = g.glob(path)
val_comp_graph = [] #List for saving the avaluation scores of all the assays in order to make a comparison bar graph
val_comp_table = [] #List for saving the avaluation scores of all the assays in order to make a comparison table
doc_names = [] #List for saving the clasification .txt files names to match the tables
for file_name in x:
        start = time.time()
        
        file = f = open(file_name,'rU') #Open the results .txt file from classifier in read mode
        cdata = file.readline() #Read the first line content

        #Declaration of the evaluation variables
        pre = [0,0,0,0,0,0,0,0,0] #Precision by clases
        pre_tot = 0.0 #Total precision
        rec = [0,0,0,0,0,0,0,0,0] #Recall by clases
        rec_tot = 0.0 #Total recall
        F_score = [0,0,0,0,0,0,0,0,0] #F-score by clases
        F_score_tot = 0 #Total F-score
        acc = [0,0,0,0,0,0,0,0,0] #Accuracy by clases
        acc_tot = 0.0 #Total Accuracy
        #Confusion matrix by clases (list position 0: true positives, 1: false positives, 2: true negatives, 3: false negatives)
        dict_MC = {"sports":[0,0,0,0], "concert":[0,0,0,0], "exhibition":[0,0,0,0], "protest":[0,0,0,0], "fashion":[0,0,0,0], "conference":[0,0,0,0], "theater_dance":[0,0,0,0], "other":[0,0,0,0], "non_event":[0,0,0,0]}
        events_gt = {} #Events in the ground truth of the clasification

        #Database connection
        db = SQL.connect(host="localhost", user="root", passwd="",db="mediaeval")
        while cdata != "": #Read of clasification .txt fileline by line
                ID = cdata[0 : cdata.find(" ")] #ID from clasified image
                clas = cdata[cdata.find(" ") + 1 : - 1] #Event from clasified image
                cursor = db.cursor()
                #Ground truth query of the image with the current ID
                cursor.execute("SELECT event_type FROM gdsa_classified WHERE document_id = " + "'" + ID + "'")
                clas_db = cursor.fetchone()[0] #Ground truth event adquisition
                if events_gt.has_key(clas_db) == False: #Ground truth events saving
                        events_gt[clas_db] = 1;

                #True positives, false positives, true negatives and false negatives calculation for each class confusion matrix
                if clas == clas_db:
                        dict_MC[clas][0] += 1
                        for i in range(len(dict_MC)):
                                if dict_MC.keys()[i] != clas:
                                        d = dict_MC.keys()[i]
                                        dict_MC[d][2] += 1
                else:
                        for i in range(len(dict_MC)):
                                if dict_MC.keys()[i] != clas_db and dict_MC.keys()[i] != clas:
                                        d = dict_MC.keys()[i]
                                        dict_MC[d][2] += 1
                                dict_MC[clas_db][3] += 1
                                dict_MC[clas][1] += 1

                cdata = file.readline() #Reading the next line
        file.close()

        #Precision, Recall, F-score and Accuracy calculation using the confusion matrix data
        for i in range(len(dict_MC)):
                d = dict_MC.keys()[i]
                if dict_MC[d][0] + dict_MC[d][1] != 0:
                        pre[i] = round(float(dict_MC[d][0]) / (dict_MC[d][0] + dict_MC[d][1]),5) #Precision by clases (5 decimal precision)
                else:
                        pre[i] = 0
                if dict_MC[d][0] + dict_MC[d][3] != 0:
                        rec[i] = round(float(dict_MC[d][0]) / (dict_MC[d][0] + dict_MC[d][3]),5) #Recall by clases (5 decimal precision)
                else:
                        rec[i] = 0
                if dict_MC[d][0] + dict_MC[d][1] + dict_MC[d][2] + dict_MC[d][3] != 0:
                        acc[i] = round(float(dict_MC[d][0] + dict_MC[d][2]) / (dict_MC[d][0] + dict_MC[d][1] + dict_MC[d][2] + dict_MC[d][3]),5) #Accuracy by clases (5 decimal precision)
                else:
                        acc[i] = 0
                if pre[i] + rec[i] != 0:
                        F_score[i] = round(2 * pre[i] * rec[i] / (pre[i] + rec[i]),5) #F-Score by clases (5 decimal precision)
                else:
                        F_score[i] = 0
        for i in range(len(dict_MC)):
                pre_tot = pre[i] + pre_tot #Average precision calculation
                rec_tot = rec[i] + rec_tot #Average Recall Calculation
                d = dict_MC.keys()[i]
                acc_tot = acc_tot + dict_MC[d][0] #Average Accuracy Calculation
                F_score_tot = F_score[i] + F_score_tot #Average F-score calculation
        num_ima = dict_MC[d][0] + dict_MC[d][1] + dict_MC[d][2] + dict_MC[d][3]
        pre_tot = round(pre_tot / len(events_gt),5) #Average Precision (5 decimal precision)
        rec_tot = round(rec_tot / len(events_gt),5) #Average Recall (5 decimal precision)
        acc_tot = round(acc_tot / num_ima,5) #Average Accuracy (5 decimal precision)
        F_score_tot = round(F_score_tot / len(events_gt),5) #Average F-score (5 decimal precision)
	
        stop = time.time()
        #print "Total time to evaluate: "+str(stop - start) + " seconds"

	#Individual evaluation results bar graph
        val_graph = [[pre[8],rec[8],F_score[8],acc[8]], [pre[4],rec[4],F_score[4], acc[4]], [pre[7],rec[7],F_score[7], acc[7]], [pre[2],rec[2],F_score[2], acc[2]], [pre[3],rec[3],F_score[3], acc[3]], [pre[0],rec[0],F_score[0], acc[0]], [pre[5],rec[5],F_score[5], acc[5]], [pre[1],rec[1],F_score[1], acc[1]], [pre[6],rec[6],F_score[6], acc[6]], [pre_tot,rec_tot,F_score_tot, acc_tot]]
        val_p = [0,0,0,0,0,0,0,0,0,0]
        val_r = [0,0,0,0,0,0,0,0,0,0]
        val_f = [0,0,0,0,0,0,0,0,0,0]
        val_a = [0,0,0,0,0,0,0,0,0,0]
        doc_names.append(file_name[10 : -4])
        for i in range(10):
                for j in range(4):
                        val_p[i] = val_graph[i][0]
                        val_r[i] = val_graph[i][1]
                        val_f[i] = val_graph[i][2]
                        val_a[i] = val_graph[i][3]    
        fig = pl.figure(figsize = (12,7))
        ind = np.arange(10)
        width = 0.20
        ax = fig.add_subplot(211)
        bar_p = ax.bar(ind, val_p, width, color='g')
        bar_r = ax.bar(ind + width, val_r, width, color='y')
        bar_f = ax.bar(ind + 2 * width, val_f, width, color='r')
        bar_a = ax.bar(ind + 3 * width, val_a, width, color='b')
        ax.set_title('Evaluation Scores of ' + file_name[10 : -4], fontweight='bold')
        ax.set_xticks(ind+2*width)
        ax.set_xticklabels( ('sports', 'concert', 'exhibition', 'protest', 'fashion', 'conference', 'theater_dance', 'other', 'non_event', 'AVERAGE'), rotation='vertical')
        ax.legend((bar_p[0], bar_r[0], bar_f[0], bar_a[0]), ('Precision', 'Recall', 'F1-Score', 'Accuracy'), loc='center left', bbox_to_anchor=(1, 0.5))
        ax.autoscale(tight=True)
        pl.subplots_adjust(right = 0.85,bottom = 0.35)
        
        val_comp_graph.append(val_graph[9][2:4])   

        #Individual evaluation results table
        val_table = [[pre[8],rec[8],F_score[8],acc[8]], [pre[4],rec[4],F_score[4], acc[4]], [pre[7],rec[7],F_score[7], acc[7]], [pre[2],rec[2],F_score[2], acc[2]], [pre[3],rec[3],F_score[3], acc[3]], [pre[0],rec[0],F_score[0], acc[0]], [pre[5],rec[5],F_score[5], acc[5]], [pre[1],rec[1],F_score[1], acc[1]], [pre[6],rec[6],F_score[6], acc[6]], [pre_tot,rec_tot,F_score_tot, acc_tot]]
        labels_fil = ('sports', 'concert', 'exhibition', 'protest', 'fashion', 'conference', 'theater_dance', 'other', 'non_event', 'AVERAGE')
        labels_col = ('Precision', 'Recall', 'F1-Score','Accuracy')
        ax = fig.add_subplot(212)
        ax.axis('off')
        table = ax.table(cellText = val_table, cellLoc = 'center', rowLabels = labels_fil, rowLoc = 'center', colLabels = labels_col, colLoc = 'center', loc = 'bottom')

        val_comp_table.append(val_table[9][2:4]) 

        pl.show()

#Evaluation results comparison bar graph
val_f = []
val_a = []
for i in range(len(val_comp_graph)):
        val_f.append(val_comp_graph[i][0])
        val_a.append(val_comp_graph[i][1])    
fig = pl.figure(figsize = (12,7))
ind = np.arange(len(val_comp_graph))
width = 0.25
ax = fig.add_subplot(211)
bar_f = ax.bar(ind, val_f, width, color='r')
bar_a = ax.bar(ind+width, val_a, width, color='b')
ax.set_title('Evaluation Scores Comparison', fontweight='bold')
ax.set_xticks(ind+width)
ax.set_xticklabels(doc_names, rotation='vertical')
ax.legend((bar_f[0], bar_a[0]), ('F1-Score', 'Accuracy'), loc='center left', bbox_to_anchor=(1, 0.5))
ax.autoscale(tight=True)
pl.subplots_adjust(right = 0.85,bottom = 0.35)

#Evaluation results comparison table
labels_fil = (doc_names)
labels_col = ('F1-Score','Accuracy')
ax = fig.add_subplot(212)
ax.axis('off')
table = ax.table(cellText = val_comp_table, cellLoc = 'center', rowLabels = labels_fil, rowLoc = 'center', colLabels = labels_col, colLoc = 'center', loc = 'bottom')

pl.show()
