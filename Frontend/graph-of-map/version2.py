import pandas as pd
import plotly.express as px
import dash
from dash import html
from dash import dcc
from dash.dependencies import Input, Output
from PIL import Image

#### LOADING DATASETS ####
#light_density = pd.read_csv("light_density.csv")
#roads_density = pd.read_csv("road_density.csv")
##########################


######FUNCTIONS IF NEEDED #########

#==========BOHAN================




##============================##

#==========TINGXUAN==============




##============================##

#==========ANDREW================




##============================##

#==========AIJIA================




##============================##




#### BUILDING APP ####
app = dash.Dash()
app.layout = html.Div(
    children=[
        #### HTML DIV TO add time slider (AIJIA)####
        html.Div(children = [
            dcc.Slider(
                id = "time-slider",
                min=0,
                max=8,
                marks = {
                    0:"8 A.M.",
                    2:"12 P.M.",
                    4:"3 P.M.",
                    6:"6 P.M.",
                    8:"9 P.M.",
                },
                value=2
            )
        ]),
        #### END DIV 1 ####
        '''
        #### HTML DIV TO add graph (AIJIA)####
        html.Div(children = [
        ], style = {}),
        #### END DIV 2 ####

        #### HTML DIV TO add INPUT for lanes (TINGXUAN)####
        html.Div(children = [
        ], style = {}),
        #### END DIV 3 ####

        #### HTML DIV TO add INPUT for traffic light waiting time (BOHAN)####
        html.Div(children = [
        ], style = {}),
        #### END DIV 4 ####

        #### HTML DIV TO add INPUT for Population Density (BOHAN)####
        html.Div(children = [
        ], style = {}),
        #### END DIV 5 ####

        #### HTML DIV TO add OUTPUT for CARS (ANDREW)####
        html.Div(children = [
        ], style = {}),
        #### END DIV 6 ####

        #### HTML DIV TO add OUTPUT for PEDESTRIANS (ANDREW)####
        html.Div(children = [
        ], style = {}),
        #### END DIV 7 ####
        '''
    ]

)







if __name__ == '__main__':
    app.run_server(debug=True, port = 8055)