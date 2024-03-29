import pandas as pd
import plotly.express as px
import dash
import numpy as np
from dash import html
from dash import dcc
from dash.dependencies import Input, Output
import dash_bootstrap_components as dbc
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import dash_daq as daq
from PIL import Image

data = pd.read_excel("real_data/full_data.xlsm", header=0)

default = {"speed_limit": 60, "num_cars": 25, "patience":60, "num_pedestrians":15}

def get_data(speed_limit, num_cars, num_ped, patience):
    data1=data[data['speed_limit'] == speed_limit]
    data2 = data1[data1['num_cars'] == num_cars]
    data3 = data2[data2['num_pedestrians'] == num_ped]
    datause = data3[data3['patience'] == patience]
    return datause




### TAB 3 GRAPHS

def create_plot_crowd_car1(speed_limit=60, num_cars = 25, num_ped = 15, patience=60):
    data = get_data(speed_limit, num_cars, num_ped, patience)
    crowds_line_df = data.groupby("light_interval").mean()[["avg_crowd_size"]]

    line1 = data[data['num_lanes'] ==1]
    line2 = data[data['num_lanes'] ==2]
    line3 = data[data['num_lanes'] ==3] 
    line4 = data[data['num_lanes'] ==4]

    car_interval1 = line1[["light_interval", "avg_speed_cars"]]
    car_interval2 = line2[["light_interval", "avg_speed_cars"]]
    car_interval3 = line3[["light_interval", "avg_speed_cars"]]
    car_interval4 = line4[["light_interval", "avg_speed_cars"]]

    fig = go.Figure()
    
    fig = make_subplots(
        rows=2, cols=1,
        vertical_spacing=0.2,
        subplot_titles=("Plot 1", 
            "Plot 2"),
        row_heights=[0.5,0.5])

    #traces for subplot 1
    trace1 =go.Scatter(
            x = car_interval1["light_interval"],
            y = car_interval1["avg_speed_cars"],
            line=dict(width=3),
            name = "number of lanes = 1",
            legendgroup='1'
        )
        
        

    trace2 =go.Scatter(
            x = car_interval2["light_interval"],
            y = car_interval2["avg_speed_cars"],
            line=dict(width=3),
            name = "number of lanes = 2",
            legendgroup='1'
        )

    trace3 =go.Scatter(
            x = car_interval3["light_interval"],
            y = car_interval3["avg_speed_cars"],
            line=dict(width=3),
            name = "number of lanes = 3",
            legendgroup='1'
        )

    trace4 =go.Scatter(
            x = car_interval4["light_interval"],
            y = car_interval4["avg_speed_cars"],
            line=dict(width=3),
            name = "number of lanes = 4",
            legendgroup='1'
        )
    
    # creating subplot 1
    fig.add_trace(trace1, row=1, col=1,),
    fig.add_trace(trace2, row=1, col=1,),
    fig.add_trace(trace3, row=1, col=1,),
    fig.add_trace(trace4, row=1, col=1,)


    tracesub2 = go.Scatter(
            x = crowds_line_df.index,
            y = crowds_line_df["avg_crowd_size"],
            line=dict(color='firebrick', width=4),
            name = "avg crowd size of pedestrians",
            legendgroup='2'
        )
    
    fig.add_trace(tracesub2,row=2, col=1,)



    fig.update_xaxes(title_text="Green Light Duration (min)",row=1, col=1)
    fig.update_yaxes(title_text="Average Speed of Cars",row=1, col=1)
    fig.update_xaxes(title_text="Green Light Duration (min)",row=2, col=1)
    fig.update_yaxes(title_text="Average Crowd Size",row=2, col=1)

    
    fig.update_layout(
        height = 600,
        width = 1000,
        showlegend=True,
        legend_tracegroupgap = 180,
        title_text = "How the Green Light Duration of Cars affect Cars and Pedestrians",
        title_x=0.5
    )


    return fig

def create_plot_crowd_car2(speed_limit=60, num_cars = 25, num_ped = 15, patience=60):
    data = get_data(speed_limit, num_cars, num_ped, patience)
    crowds_line_df = data.groupby("light_interval").mean()[["avg_crowd_size"]]

    line1 = data[data['num_lanes'] ==1]
    line2 = data[data['num_lanes'] ==2]
    line3 = data[data['num_lanes'] ==3] 
    line4 = data[data['num_lanes'] ==4]

    car_interval1 = line1[["light_interval", "changed_lanes"]]
    car_interval2 = line2[["light_interval", "changed_lanes"]]
    car_interval3 = line3[["light_interval", "changed_lanes"]]
    car_interval4 = line4[["light_interval", "changed_lanes"]]

    fig = go.Figure()
    
    fig = make_subplots(
        rows=2, cols=1,
        vertical_spacing=0.2,
        subplot_titles=("Plot 1", 
            "Plot 2"),
        row_heights=[0.5,0.5])

    #traces for subplot 1
    trace1 =go.Scatter(
            x = car_interval1["light_interval"],
            y = car_interval1["changed_lanes"],
            line=dict(width=3),
            name = "plot1: number of lanes = 1",
            legendgroup='1'
        )
        
        

    trace2 =go.Scatter(
            x = car_interval2["light_interval"],
            y = car_interval2["changed_lanes"],
            line=dict(width=3),
            name = "plot1: number of lanes = 2",
            legendgroup='1'
        )

    trace3 =go.Scatter(
            x = car_interval3["light_interval"],
            y = car_interval3["changed_lanes"],
            line=dict(width=3),
            name = "plot1: number of lanes = 3",
            legendgroup='1'
        )

    trace4 =go.Scatter(
            x = car_interval4["light_interval"],
            y = car_interval4["changed_lanes"],
            line=dict(width=3),
            name = "plot1: number of lanes = 4",
            legendgroup='1'
        )
    
    # creating subplot 1
    fig.add_trace(trace1, row=1, col=1,),
    fig.add_trace(trace2, row=1, col=1,),
    fig.add_trace(trace3, row=1, col=1,),
    fig.add_trace(trace4, row=1, col=1,)


    tracesub2 = go.Scatter(
            x = crowds_line_df.index,
            y = crowds_line_df["avg_crowd_size"],
            line=dict(color='firebrick', width=4),
            name = "plot2: avg crowd size of pedestrians",
            legendgroup='2'
        )
    
    fig.add_trace(tracesub2,row=2, col=1,)



    fig.update_xaxes(title_text="Green Light Duration (min)",row=1, col=1)
    fig.update_yaxes(title_text="Lane Changes per min",row=1, col=1)
    fig.update_xaxes(title_text="Green Light Duration (min)",row=2, col=1)
    fig.update_yaxes(title_text="Average Crowd Size",row=2, col=1)

    
    fig.update_layout(
        height = 600,
        width = 1000,
        showlegend=True,
        legend_tracegroupgap = 180,
        title_text = "How the Green Light Duration of Cars affect Cars and Pedestrians",
        title_x=0.5
    )


    return fig


def create_plot_tab3(comp = 1, speed_limit=60, num_cars = 25, num_ped = 15, patience=60):
    if comp == 1:
        fig = create_plot_crowd_car1(speed_limit, num_cars, num_ped, patience)
    else:
        fig = create_plot_crowd_car2(speed_limit, num_cars, num_ped, patience)
    return fig
### TAB 2 GRAPHS

#### Graph 1: plot with 2 output 2 inputs, x = num.lanes, y=light interval, color = speed, size = changed lanes
def create_cars_plot1(speed_limit=60, num_cars = 25, num_ped = 15, patience=60):
    data = get_data(speed_limit, num_cars, num_ped, patience)
    car_marker_df = data[["num_lanes", "light_interval", "avg_speed_cars", "changed_lanes"]]
    #car_marker_df = car_marker_df.groupby(["num_lanes", "light_interval"])["avg_speed_cars", "changed_lanes"].mean().reset_index()
    fig = px.scatter(car_marker_df, x="num_lanes", 
        y="light_interval", 
        color="changed_lanes", 
        size = "avg_speed_cars", 
        title="Map of Speed & Lane changes per min VS No. of lanes & Green Light Duration",
        labels=dict(light_interval="Green light duration for cars", num_lanes="Number of Lanes", changed_lanes="Lane changes per min", avg_speed_cars = "Average speed of cars")
    )
    fig.update_traces(mode="markers")
    return fig


#### Graph 2: heat map of speed vs num lanes and light int

def create_cars_plot2(speed_limit=60, num_cars = 25, num_ped = 15, patience=60):
    data = get_data(speed_limit, num_cars, num_ped, patience)
    car_heat_df1 = data[["num_lanes", "light_interval", "avg_speed_cars"]]
    
    fig = make_subplots(
        rows=1, cols=1,
        #subplot_titles=("Speed vs Num lanes & Light int")
        )

    fig.add_trace(
        go.Heatmap(x = car_heat_df1["num_lanes"],
            y =  car_heat_df1["light_interval"],
            z =  car_heat_df1["avg_speed_cars"],
            hovertemplate='Number of Lanes: %{x}<br>Green Light Duration: %{y}<br>Avg Speed of Cars: %{z}'
        ),
        row=1, col=1,
    )    
    fig.update_xaxes(title_text="Number of Lanes", row=1, col=1)
    fig.update_yaxes(title_text="Green Light Duration (min)", row=1, col=1)
    fig.update_layout(
        height = 600,
        width = 500,
        title_text = "Speed <br>VS <br>No. of lanes & Green Light Duration",
        title_x=0.5,
        showlegend=True
    )

    return fig

#### Graph 3: subplot of speed vs num lanes and speed vs light int
def create_cars_plot3(speed_limit=60, num_cars = 25, num_ped = 15, patience=60):
    data = get_data(speed_limit, num_cars, num_ped, patience)

    #for speed vs light int graph
    line1 = data[data['num_lanes'] ==1]
    line2 = data[data['num_lanes'] ==2]
    line3 = data[data['num_lanes'] ==3]
    line4 = data[data['num_lanes'] ==4]

    car_interval1 = line1[["light_interval", "avg_speed_cars"]]
    car_interval2 = line2[["light_interval", "avg_speed_cars"]]
    car_interval3 = line3[["light_interval", "avg_speed_cars"]]
    car_interval4 = line4[["light_interval", "avg_speed_cars"]]

    #for speed vs lanes graph
    interval1 = data[data['light_interval'] ==0.5]
    interval2 = data[data['light_interval'] ==1.0]
    interval3 = data[data['light_interval'] ==1.5]
    interval4 = data[data['light_interval'] ==2.0]

    car_lanes1 = interval1[["num_lanes","avg_speed_cars"]]
    car_lanes2 = interval2[["num_lanes","avg_speed_cars"]]
    car_lanes3 = interval3[["num_lanes","avg_speed_cars"]]
    car_lanes4 = interval4[["num_lanes","avg_speed_cars"]]

    #plotting the subplot
    fig = make_subplots(
        rows=2, cols=1,
        vertical_spacing=0.3,
        subplot_titles=("Plot 1",
            "Plot 2"
            ),
        row_heights=[0.5,0.5])

    #traces for subplot 1 (speed vs light int)
    trace1 =go.Line(x = car_interval1["light_interval"],
        y = car_interval1["avg_speed_cars"],
        name = "number of lanes = 1",
        legendgroup='1'
        )

    trace2 =go.Line(x = car_interval2["light_interval"],
        y = car_interval2["avg_speed_cars"],
        name = "number of lanes = 2",
        legendgroup='1'
        )

    trace3 =go.Line(x = car_interval3["light_interval"],
        y = car_interval3["avg_speed_cars"],
        name = "number of lanes = 3",
        legendgroup='1'
        )

    trace4 =go.Line(x = car_interval4["light_interval"],
        y = car_interval4["avg_speed_cars"],
        name = "number of lanes = 4",  
        legendgroup='1'             
        )
    
    # creating subplot 1
    fig.add_trace(trace1, row=1, col=1,),
    fig.add_trace(trace2, row=1, col=1,),
    fig.add_trace(trace3, row=1, col=1,),
    fig.add_trace(trace4, row=1, col=1,)

    #traces for subplot 2 (speed vs num of lanes)
    trace_1 = go.Line(x = car_lanes1["num_lanes"],
                      y = car_lanes1["avg_speed_cars"],
                      name = "green light duration (min) = 0.5",
                      legendgroup='2')
    trace_2 = go.Line(x = car_lanes2["num_lanes"],
                      y = car_lanes2["avg_speed_cars"],
                      name = "green light duration (min) = 1.0",
                      legendgroup='2'
                      )
    trace_3 = go.Line(x = car_lanes3["num_lanes"],
                      y = car_lanes3["avg_speed_cars"],
                      name = "green light duration (min) = 1.5",
                      legendgroup='2'
                      )
    trace_4 = go.Line(x = car_lanes4["num_lanes"],
                      y = car_lanes4["avg_speed_cars"],
                      name = "green light duration (min) = 2.0",
                      legendgroup='2'
                      )
    
    fig.add_trace(trace_1,
        row=2, col=1,
        )
    fig.add_trace(trace_2,
        row=2, col=1,
        )
    fig.add_trace(trace_3,
        row=2, col=1,
        )
    fig.add_trace(trace_4,
        row=2, col=1,
        )

    # axis titles
    fig.update_xaxes(title_text="Green Light Duration (min)", row=1, col=1)
    fig.update_xaxes(title_text="Number of Lanes", row=2, col=1)

    fig.update_yaxes(title_text="Average Speed of Cars", row=1, col=1)
    fig.update_yaxes(title_text="Average Speed of Cars", row=2, col=1)

    fig.update_layout(
        height = 600,
        width = 700,
        showlegend=True,
        legend_tracegroupgap = 180
    )
    return fig

#### Graph 4: heat map of change lanes vs num lanes and light int
def create_cars_plot4(speed_limit=60, num_cars = 25, num_ped = 15, patience=60):
    data = get_data(speed_limit, num_cars, num_ped, patience)
    car_heat_df2 = data[["num_lanes", "light_interval", "changed_lanes"]]
    fig = make_subplots(
        rows=1, cols=1,
        #subplot_titles=("Change lanes vs Num lanes & Light int")
        )
    fig.add_trace(
        go.Heatmap(x = car_heat_df2["num_lanes"],
            y =  car_heat_df2["light_interval"],
            z =  car_heat_df2["changed_lanes"],
            hovertemplate='Number of Lanes: %{x}<br>Green Light Duration: %{y}<br>Lane changes per min: %{z}'),
        row=1, col=1,
    )    
    fig.update_xaxes(title_text="Number of Lanes", row=1, col=1)
    fig.update_yaxes(title_text="Green Light Duration (min)", row=1, col=1)
    fig.update_layout(
        height = 600,
        width = 500,
        title_text = "Lane changes per min <br>VS <br>No. of lanes & Green Light Duration",
        title_x=0.5,
        showlegend=True,
        #legend_tracegroupgap = 180
    )
    return fig

#### Graph 5: subplot of change lanes vs num lanes and change lanes vs light int
def create_cars_plot5(speed_limit=60, num_cars = 25, num_ped = 15, patience=60):
    data = get_data(speed_limit, num_cars, num_ped, patience)

    #for speed vs light int graph
    line1 = data[data['num_lanes'] ==1]
    line2 = data[data['num_lanes'] ==2]
    line3 = data[data['num_lanes'] ==3]
    line4 = data[data['num_lanes'] ==4]

    car_interval1 = line1[["light_interval", "changed_lanes"]]
    car_interval2 = line2[["light_interval", "changed_lanes"]]
    car_interval3 = line3[["light_interval", "changed_lanes"]]
    car_interval4 = line4[["light_interval", "changed_lanes"]]

    #for speed vs lanes graph
    interval1 = data[data['light_interval'] ==0.5]
    interval2 = data[data['light_interval'] ==1.0]
    interval3 = data[data['light_interval'] ==1.5]
    interval4 = data[data['light_interval'] ==2.0]

    car_lanes1 = interval1[["num_lanes","changed_lanes"]]
    car_lanes2 = interval2[["num_lanes","changed_lanes"]]
    car_lanes3 = interval3[["num_lanes","changed_lanes"]]
    car_lanes4 = interval4[["num_lanes","changed_lanes"]]

    #plotting the subplot
    fig = make_subplots(
        rows=2, cols=1,
        vertical_spacing=0.3,
        subplot_titles=("Plot 1",
            "Plot 2"
            ),
        row_heights=[0.5,0.5])

    #traces for subplot 1 (speed vs light int)
    trace1 =go.Line(x = car_interval1["light_interval"],
        y = car_interval1["changed_lanes"],
        name = "number of lanes = 1",
        legendgroup='1'
        )
 
    trace2 =go.Line(x = car_interval2["light_interval"],
        y = car_interval2["changed_lanes"],
        name = "number of lanes = 2",
        legendgroup='1'
        )

    trace3 =go.Line(x = car_interval3["light_interval"],
        y = car_interval3["changed_lanes"],
        name = "number of lanes = 3",
        legendgroup='1'
        )

    trace4 =go.Line(x = car_interval4["light_interval"],
        y = car_interval4["changed_lanes"],
        name = "number of lanes = 4",   
        legendgroup='1'            
        )
    
    # creating subplot 1
    fig.add_trace(trace1, row=1, col=1,),
    fig.add_trace(trace2, row=1, col=1,),
    fig.add_trace(trace3, row=1, col=1,),
    fig.add_trace(trace4, row=1, col=1,)

    #traces for subplot 1 (speed vs num of lanes)
    trace_1 = go.Line(x = car_lanes1["num_lanes"],
                      y = car_lanes1["changed_lanes"],
                      name = "green light duration (min) = 0.5",
                      legendgroup='2')

    trace_2 = go.Line(x = car_lanes2["num_lanes"],
                      y = car_lanes2["changed_lanes"],
                      name = "green light duration (min) = 1.0",
                      legendgroup='2'
                      )

    trace_3 = go.Line(x = car_lanes3["num_lanes"],
                      y = car_lanes3["changed_lanes"],
                      name = "green light duration (min) = 1.5",
                      legendgroup='2'
                      )

    trace_4 = go.Line(x = car_lanes4["num_lanes"],
                      y = car_lanes4["changed_lanes"],
                      name = "green light duration (min) = 2.0",
                      legendgroup='2'
                      )
    
    fig.add_trace(trace_1,
        row=2, col=1,
        )
    fig.add_trace(trace_2,
        row=2, col=1,
        )
    fig.add_trace(trace_3,
        row=2, col=1,
        )
    fig.add_trace(trace_4,
        row=2, col=1,
        )

    # axis titles
    fig.update_xaxes(title_text="Green Light Duration (min) ", row=1, col=1)
    fig.update_xaxes(title_text="Number of Lanes", row=2, col=1)

    fig.update_yaxes(title_text="Number of lane changes per min", row=1, col=1)
    fig.update_yaxes(title_text="Number of lane changes per min", row=2, col=1)

    fig.update_layout(
        height = 600,
        width = 700,
        showlegend=True,
        legend_tracegroupgap = 180
    )
    return fig



### THE APP


app = dash.Dash(external_stylesheets=[dbc.themes.BOOTSTRAP, 'https://codepen.io/chriddyp/pen/bWLwgP.css'])

#### TAB 1 CONTENT
content1 = dbc.Row([
    dbc.Col([
        html.H6("Number of Lanes (1 - 4)"),
        html.Div(
            [
                dcc.Dropdown(['1', '2', '3', '4'], 
                '2', 
                id='lane-dropdown'),
                html.Div(id='number-of-lanes')
            ]
        ),
        html.Br(),

        #dbc.Button("Decrease Lane", id = "decrease_lane", color = "secondary", className = "me-1", n_clicks = 0),
        #html.Br(),
        #html.Span(id="number-of-lanes", style={"verticalAlign": "middle"}),
        #html.Br(),
        #dbc.Button("Increase Lane", id = "increase_lane", color = "secondary", className = "me-1", n_clicks = 2),
        
        html.H6("Green Light Duration of Cars (0.5 - 2 mins)"),
        html.Div(
            [
                dbc.Button("-", id = "decrease_light", color = "danger", className = "me-1", n_clicks = 0),
                html.Span(id="light-interval", style={"verticalAlign": "middle"}),
                dbc.Button("+", id = "increase_light", color = "success", className = "me-1", n_clicks = 1),
            ], style = {'align-items': 'center', 'justify-content': 'center'}
        ),
        html.Br(),
        html.H6("Options"),
        dcc.Dropdown(
            id = 'dropdown-to-show_or_hide-element',
            options=[
                {'label': 'Show explanation', 'value': 'on'},
                {'label': 'Hide explanation', 'value': 'off'}
            ],
        value = 'off'
        ),
        html.Br(),
        html.Br(),
        html.Br(),
        html.Div([
            html.Button("Download CSV", id="btn_csv"),
            dcc.Download(id="download-dataframe-csv"),
        ])
    ], width = 3),
    dbc.Col([
        html.H6("Junction Statistics"),
        dbc.Row([
            dbc.Col([daq.Gauge(
                    showCurrentValue=True,
                    color={"gradient":True, 
                            "ranges":{"green": [45, 80], "yellow": [30, 45], "red":[15, 30], "purple": [0, 15]}},
                    scale={'start': 0, 'interval': 5, 'labelInterval': 2},
                    units="km/h",
                    id='test01',
                    label="Average Car Speed", 
                    max= 80,
                    min= 0,
                    size = 200
                )], width = 5),
            dbc.Col([daq.Tank(
                    showCurrentValue=True,
                    scale={'interval': 5, 'labelInterval': 1},
                    units="People",
                    id = "test02",
                    label='Average Crowd Size',
                    max=30,
                    min=0,
                )], width = 3),
            dbc.Col([daq.Thermometer(
                    showCurrentValue=True,
                    scale={'interval': 0.05, 'labelInterval': 2},
                    units="Changes",
                    id = "test03",
                    label='Lane changes per min',
                    max=0.5,
                    min=0,
                    height = 120,
                )], width = 3),
        ]) ,
        dbc.Row([
            dbc.Col([
                html.Div(id = "element-to-hide",
                children = [
                    html.H6("Explanation"),
                    html.Span(id = "paragraph")
                ], style= {'display': 'block'})
            ], width = 10)
        ])   
            ]
        ),
    ])

### TAB 2 CONTENT
content2 = dcc.Tabs(id = "car-graph-tabs", children = [
    dcc.Tab([
        dcc.Graph(id = "cars_plot1", figure=create_cars_plot1())
    ], label = "An Overview"),
    dcc.Tab([
        dbc.Row([
                dbc.Col([
                    dcc.Graph(id = "cars_plot4", figure=create_cars_plot4())
                ], width = 5), #heatmap of num_change_lanes vs num_lanes and light int
                dbc.Col([
                    dcc.Graph(id = "cars_plot5", figure=create_cars_plot5())
                ], width = 7) #subplots of num_change_lanes
            ])
    ], label = "Rate of lane changes"),
    dcc.Tab([
        dbc.Row([
                dbc.Col([
                    dcc.Graph(id = "cars_plot2", figure=create_cars_plot2())
                    ], width = 5), #heatmap of speed vs num_lanes and light int
                dbc.Col([
                    dcc.Graph(id = "cars_plot3", figure=create_cars_plot3())
                ], width = 7) #subplots of speed
            ])
    ], label = "Car speed")
])

###TAB 3 CONTENT
content3 = html.Div([
    html.Div([
                html.Label(['Choose a Comparison:']),
                dcc.RadioItems(
                    id='radio',
                    options=[
                             {'label': 'Average Speed of Cars', 'value': 1},
                             {'label': 'Lane Changes per min', 'value': 2},
                    ], 
                    value=1, 
                    inline=True
                ),
        ]),
    html.Div(
        dcc.Graph(id='comparing-graph',figure=create_plot_tab3()),
    )
    

])


### OVERALL

## SIDEBAR

sidebar = html.Div([
    dbc.Row(children=[
        html.H4(children=["Environmental Variables"],
                style={"text-align": "left",
                "color": "#4aa9d4"})
    ]),
    html.H6("Speed Limit"),
    dcc.Slider(id = "speed-limit", min = 40, max = 80, step = 10,
    marks={
        40: "40",
        50: "50",
        60: "60",
        70: "70",
        80: "80"
    }, value=60, 
        tooltip={"placement": "bottom", "always_visible": True}),

    html.P(
        "The speed limit at the junction"
    ),
    
    html.Br(),

    html.H6("Number of Cars"),
    dcc.Slider(id = "number-of-cars", min = 25, max = 65, step = 10,
    marks={
        25: "25",
        35: "35",
        45: "45",
        55: "55",
        65: "65"
    }, value=25, 
        tooltip={"placement": "bottom", "always_visible": True}),

    html.P(
        "How many drivers are in the neighborhood"
    ),

    html.Br(),

    html.H6("Number of Pedestrians"),
    dcc.Slider(id = "number-of-pedestrians", min = 5, max = 35, step = 10,
    marks={
        5: "5",
        15: "15",
        25: "25",
        35: "35"
    }, 
    value=15, 
        tooltip={"placement": "bottom", "always_visible": True}),

    html.P(
        "How many pedestrians are in the neighborhood"
    ),

    html.Br(),

    html.H6("Driver patience"),
    dcc.Slider(id = "max-patience", min = 20, max = 100, step = 20, value=60, 
        tooltip={"placement": "bottom", "always_visible": True}),

    html.P(
        "How patient the drivers are"
    ),
])

### TABS

tabs = dbc.Tabs([
    dbc.Tab([
        content1
    ], label = "Exploration"), 
    dbc.Tab([
        content2
    ], label = "How are cars affected"),
    dbc.Tab([
        content3
    ], label = "How are cars and pedestrians affected")
])

pil_image = Image.open("assets/background.jpg")
pil_logo = Image.open("assets/logo.jpg")


app.layout = html.Div(
    children=[
        dbc.Row([ html.Img(src = pil_image)
        ]),
        html.Br(),
        dbc.Row([ 
            dbc.Col([
                sidebar
            ], width = 2),
            dbc.Col([
                tabs
            ], width = 10)
        ]),
        html.Br(),
        html.Br(),
        dbc.Row([
            html.Div([ html.Img(src = pil_logo, style={'height':'100%', 'width':'20%'})
            ])
        ], style = {'textAlign': 'right'})
           
    ],
    style={"margin-left": "20px", "margin-right": "20px", "margin-top": "15px"}
)


#####CALLBACKS

# callback for lane buttons
#@app.callback(
#    Output("number-of-lanes", "children"), [Input("increase_lane", "n_clicks"), Input("decrease_lane", "n_clicks")]
#)
#def on_button_click(n, m):
#    lanes = n - m
#    lanes = max(min(lanes, 4), 1)
#    if lanes == 1:
#        return "1 lane"
#    return f"{lanes} lanes"


# call back for lane dropdown 
@app.callback(
    Output('number-of-lanes', 'children'),
    Input('lane-dropdown', 'value')
)

def update_output(value):
    return f"{value} lanes"

# callback for light interval buttons
@app.callback(
    Output("light-interval", "children"), [Input("increase_light", "n_clicks"), Input("decrease_light", "n_clicks")]
)
def on_button_click(n, m):
    value = (n - m) / 2
    value = max(min(value, 2), 0.5)
    return format(value, '.1f')

# callback from sidebar to tab 1
@app.callback(
    Output("test01", "value"), 
    [Input("speed-limit", "value"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value"),
    Input("number-of-lanes", "children"),
    Input("light-interval", "children"),]
)
def get_value(sl, nc, np, mp, nl, li):
    datause = get_data(sl, nc, np, mp)
    data3 = datause[datause['num_lanes'] == int(nl[0])]
    data4 = data3[data3['light_interval'] == float(li)]
    return_value = data4['avg_speed_cars'].iloc[0]
    return return_value

@app.callback(
    Output("test02", "value"), 
    [Input("speed-limit", "value"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value"),
    Input("number-of-lanes", "children"),
    Input("light-interval", "children"),]
)
def get_value(sl, nc, np, mp, nl, li):
    datause = get_data(sl, nc, np, mp)
    data3 = datause[datause['num_lanes'] == int(nl[0])]
    data4 = data3[data3['light_interval'] == float(li)]
    return_value = data4['avg_crowd_size'].iloc[0]
    return round(return_value, 1)

@app.callback(
    Output("test03", "value"), 
    [Input("speed-limit", "value"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value"),
    Input("number-of-lanes", "children"),
    Input("light-interval", "children"),]
)
def get_value(sl, nc, np, mp, nl, li):
    datause = get_data(sl, nc, np, mp)
    data3 = datause[datause['num_lanes'] == int(nl[0])]
    data4 = data3[data3['light_interval'] == float(li)]
    return_value = data4['changed_lanes'].iloc[0]
    return round(return_value, 2)

@app.callback(
    Output("paragraph", "children"), 
    [Input("test01", "value"),
    Input("test02", "value"),
    Input("test03", "value"),]
)
def get_description(o1, o2, o3):
    cutoff = (35, 10, 0.1)
    bad = (o1 < cutoff[0], o2 > cutoff[1], o3 > cutoff[2])
    output = ""
    if bad == (False, False, False):
        output += f"The average car speed is {round(o1,1)} kilometers per hour, \
            meaning that traffic flows considerably freely near the junction. \n\
            The average crowd size is {o2} people, indicating that the pedestrians are able to walk around effortlessly. \n\
            The number of lane changes per min is {o3}, suggesting that accidents are less likely to happen. \n"
    
    elif bad == (False, False, True):
        output += f"The average car speed is {round(o1,1)} kilometers per hour, \
            meaning that traffic flows considerably freely near the junction. \
            The average crowd size is {o2} people, indicating that the pedestrians are able to walk around effortlessly. \
            However, the number of lane changes per min is {o3}, suggesting that there is a high risk of accidents. "

    elif bad == (False, True, False):
        output += f"The average car speed is {round(o1,1)} kilometers per hour, \
            meaning that traffic flows considerably freely near the junction. \
            The number of lane changes per min is {o3}, suggesting that accidents are less likely to happen. \
            However, the average crowd size is {o2} people, indicating that the pedestrians may face difficulties walking around. "

    elif bad == (False, True, True):
        output += f"The average car speed is {round(o1,1)} kilometers per hour, \
            meaning that traffic flows considerably freely near the junction. \
            However, the average crowd size is {o2} people, indicating that the pedestrians may face difficulties walking around. \
            Moreover, the number of lane changes per min is {o3}, suggesting that there is a high risk of accidents. " 

    elif bad == (True, False, False):
        output += f"The average crowd size is {o2} people, indicating that the pedestrians are able to walk around effortlessly. \
            The number of lane changes per min is {o3}, suggesting that accidents are less likely to happen. \
            However, the average car speed is only {round(o1,1)} kilometers per hour, \
            meaning that congestion happens frequently near the junction. "

    elif bad == (True, False, True):
        output += f"The average crowd size is {o2} people, indicating that the pedestrians are able to walk around effortlessly. \
            However, the average car speed is only {round(o1,1)} kilometers per hour, \
            meaning that congestion happens frequently near the junction. \
            Moreover, the number of lane changes per min is {o3}, suggesting that there is a high risk of accidents. "

    elif bad == (True, True, False):
        output += f"The number of lane changes per min is {o3}, suggesting that accidents are less likely to happen. \
            However, the average car speed is only {round(o1,1)} kilometers per hour, \
            meaning that congestion happens frequently near the junction. \
            Moreover, the average crowd size is {o2} people, indicating that the pedestrians may face difficulties walking around. "

    else:
        output += f"The average car speed is only {round(o1,1)} kilometers per hour, \
            meaning that congestion happens frequently near the junction. \
            Moreover, the average crowd size is {o2} people, indicating that the pedestrians may face difficulties walking around. \
            On top of that, the number of lane changes per min is {o3}, suggesting that there is a high risk of accidents. "

    bad_qualities = bad.count(True)
    if bad_qualities == 0:
        output += "Based on the three metrics, this is a very effective junction design!"

    elif bad_qualities == 1:
        output += "Based on the three metrics, this is a decent junction design!"

    elif bad_qualities == 2:
        output += "Based on the three metrics, this junction design has some room for improvement!"
    
    else:
        output += "Based on the three metrics, this junction design is inadequate."

    return output

@app.callback(
   Output(component_id='element-to-hide', component_property='style'),
   [Input(component_id='dropdown-to-show_or_hide-element', component_property='value')]
)
def show_hide_element(visibility_state):
    if visibility_state == 'on':
        return {'display': 'block'}
    if visibility_state == 'off':
        return {'display': 'none'}

@app.callback(
    Output("download-dataframe-csv", "data"),
    Input("btn_csv", "n_clicks"),
    prevent_initial_call=True,
)
def func(n_clicks):
    return dcc.send_data_frame(data.to_csv, "data.csv")

# Callback from sidebar to tab 3
@app.callback(
    Output("comparing-graph", "figure"),
    Input('radio', 'value'),
    Input("speed-limit", "value"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_crowd(r, sp, nc, np, mp):
    if sp:
        default["speed_limit"]=sp
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    crowd_car_fig = create_plot_tab3(r, default["speed_limit"], default["num_cars"], default["num_pedestrians"], default["patience"])
    return crowd_car_fig



# Callback from sidebar to tab-2-2
# plot 1

@app.callback(
    Output("cars_plot1", "figure"),
    Input("speed-limit", "value"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_cars1(sp, nc, np, mp):
    if sp:
        default["speed_limit"]=sp
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    car_fig = create_cars_plot1(default["speed_limit"], default["num_cars"], default["num_pedestrians"], default["patience"])
    return car_fig

# plot 2
@app.callback(
    Output("cars_plot2", "figure"),
    Input("speed-limit", "value"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_cars2(sp, nc, np, mp):
    if sp:
        default["speed_limit"]=sp
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    car_fig = create_cars_plot2(default["speed_limit"], default["num_cars"], default["num_pedestrians"], default["patience"])
    return car_fig

# plot 3
@app.callback(
    Output("cars_plot3", "figure"),
    Input("speed-limit", "value"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_cars3(sp, nc, np, mp):
    if sp:
        default["speed_limit"]=sp
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    car_fig = create_cars_plot3(default["speed_limit"], default["num_cars"], default["num_pedestrians"], default["patience"])
    return car_fig

# plot 4
@app.callback(
    Output("cars_plot4", "figure"),
    Input("speed-limit", "value"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_cars4(sp, nc, np, mp):
    if sp:
        default["speed_limit"]=sp
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    car_fig = create_cars_plot4(default["speed_limit"], default["num_cars"], default["num_pedestrians"], default["patience"])
    return car_fig

# plot 5
@app.callback(
    Output("cars_plot5", "figure"),
    Input("speed-limit", "value"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_cars5(sp, nc, np, mp):
    if sp:
        default["speed_limit"]=sp
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    car_fig = create_cars_plot5(default["speed_limit"], default["num_cars"], default["num_pedestrians"], default["patience"])
    return car_fig



if __name__ == '__main__':
    app.run_server(host = '0.0.0.0', debug=False, port = 8055)
