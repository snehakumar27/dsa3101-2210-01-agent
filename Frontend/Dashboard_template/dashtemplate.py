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
import plotly.express as px

data = pd.read_excel("permsnewdata.xlsx", header=0)

default = {"num_cars": 10, "patience":0.6, "num_pedestrians":10}

def get_data(num_cars, num_ped, patience):
    data1 = data[data['num_cars'] == num_cars]
    data2 = data1[data1['num_pedestrians'] == num_ped]
    datause = data2[data2['patience'] == patience]
    return datause



### TAB 3 GRAPHS
def create_plot_crowd_car(num_cars = 10, num_ped = 10, patience=0.6):
    data = get_data(num_cars, num_ped, patience)
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
    fig.add_trace(
        go.Scatter(
            x = crowds_line_df.index,
            y = crowds_line_df["avg_crowd_size"],
            line=dict(color='firebrick', width=4),
            name = "avg crowd size of pedestrians"
        )
    )

    fig.add_trace(
        go.Scatter(
            x = car_interval1["light_interval"],
            y = car_interval1["avg_speed_cars"],
            line=dict(width=3, dash='dash'),
            name = "number of lanes = 1"
        )
    )
    fig.add_trace(
        go.Scatter(
            x = car_interval2["light_interval"],
            y = car_interval2["avg_speed_cars"],
            line=dict(width=3, dash='dash'),
            name = "number of lanes = 2"
        )
    )

    fig.add_trace(
        go.Scatter(
            x = car_interval3["light_interval"],
            y = car_interval3["avg_speed_cars"],
            line=dict(width=3, dash='dash'),
            name = "number of lanes = 3"
        )
    )

    fig.add_trace(
        go.Scatter(
            x = car_interval4["light_interval"],
            y = car_interval4["avg_speed_cars"],
            line=dict(width=3, dash='dash'),
            name = "number of lanes = 4"
        )
    )

    fig.update_xaxes(title_text="Light Interval")
    fig.update_yaxes(title_text="Condition for cars and pedestrians")

    fig.update_layout(
        height = 600,
        width = 1000,
        showlegend=True,
        title_text = "How the Green Light Interval of Cars affect Cars and Pedestrians"
    )


    return fig



### TAB 2 GRAPHS

#### Graph 1: plot with 2 output 2 inputs, x = num.lanes, y=light interval, color = speed, size = changed lanes
def create_cars_plot1(num_cars = 10, num_ped = 10, patience=0.6):
    data = get_data(num_cars, num_ped, patience)
    car_marker_df = data[["num_lanes", "light_interval", "avg_speed_cars", "changed_lanes"]]
    #car_marker_df = car_marker_df.groupby(["num_lanes", "light_interval"])["avg_speed_cars", "changed_lanes"].mean().reset_index()
    fig = px.scatter(car_marker_df, x="num_lanes", 
        y="light_interval", 
        color="changed_lanes", 
        size = "avg_speed_cars", 
        title="Map of Speed & Lane changing vs Num lanes & Light int",
        labels=dict(light_interval="Green light interval for cars", num_lanes="Number of Lanes", changed_lanes="Count of Lane Changing", avg_speed_cars = "Average speed of cars")
    )
    fig.update_traces(mode="markers")
    return fig


#### Graph 2: heat map of speed vs num lanes and light int

def create_cars_plot2(num_cars = 10, num_ped = 10, patience=0.6):
    data = get_data(num_cars, num_ped, patience)
    car_heat_df1 = data[["num_lanes", "light_interval", "avg_speed_cars"]]
    
    fig = make_subplots(
        rows=1, cols=1,
        #subplot_titles=("Speed vs Num lanes & Light int")
        )

    fig.add_trace(
        go.Heatmap(x = car_heat_df1["num_lanes"],
            y =  car_heat_df1["light_interval"],
            z =  car_heat_df1["avg_speed_cars"],
            hovertemplate='Number of Lanes: %{x}<br>Green Light Interval: %{y}<br>Avg Speed of Cars: %{z}'
        ),
        row=1, col=1,
    )    
    fig.update_xaxes(title_text="Number of Lanes", row=1, col=1)
    fig.update_yaxes(title_text="Light Interval", row=1, col=1)
    fig.update_layout(
        height = 600,
        width = 500,
        title_text = "Speed vs Num lanes & Light int",
        showlegend=True
    )

    return fig

#### Graph 3: subplot of speed vs num lanes and speed vs light int
def create_cars_plot3(num_cars = 10, num_ped = 10, patience=0.6):
    data = get_data(num_cars, num_ped, patience)

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
        subplot_titles=("Avg speed of cars vs light interval",
            "Avg speed of cars vs number of lanes"
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
        )

    trace3 =go.Line(x = car_interval3["light_interval"],
        y = car_interval3["avg_speed_cars"],
        name = "number of lanes = 3",
        )

    trace4 =go.Line(x = car_interval4["light_interval"],
        y = car_interval4["avg_speed_cars"],
        name = "number of lanes = 4",               
        )
    
    # creating subplot 1
    fig.add_trace(trace1, row=1, col=1,),
    fig.add_trace(trace2, row=1, col=1,),
    fig.add_trace(trace3, row=1, col=1,),
    fig.add_trace(trace4, row=1, col=1,)

    #traces for subplot 1 (speed vs num of lanes)
    trace_1 = go.Line(x = car_lanes1["num_lanes"],
                      y = car_lanes1["avg_speed_cars"],
                      name = "light_interval = 0.5",
                      legendgroup='2')
    trace_2 = go.Line(x = car_lanes2["num_lanes"],
                      y = car_lanes2["avg_speed_cars"],
                      name = "light_interval = 1.0",
                      #legendgroup='1'
                      )
    trace_3 = go.Line(x = car_lanes3["num_lanes"],
                      y = car_lanes3["avg_speed_cars"],
                      name = "light_interval = 1.5",
                      #legendgroup='1'
                      )
    trace_4 = go.Line(x = car_lanes4["num_lanes"],
                      y = car_lanes4["avg_speed_cars"],
                      name = "light_interval = 2.0",
                      #legendgroup='1'
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
    fig.update_xaxes(title_text="Light Interval", row=1, col=1)
    fig.update_xaxes(title_text="Number of Lanes", row=2, col=1)

    fig.update_yaxes(title_text="Average Speed of Cars", row=1, col=1)
    fig.update_yaxes(title_text="Average Speed of Cars", row=2, col=1)

    fig.update_layout(
        height = 600,
        width = 600,
        showlegend=True
    )
    return fig

#### Graph 4: heat map of change lanes vs num lanes and light int
def create_cars_plot4(num_cars = 10, num_ped = 10, patience=0.6):
    data = get_data(num_cars, num_ped, patience)
    car_heat_df2 = data[["num_lanes", "light_interval", "changed_lanes"]]
    fig = make_subplots(
        rows=1, cols=1,
        #subplot_titles=("Change lanes vs Num lanes & Light int")
        )
    fig.add_trace(
        go.Heatmap(x = car_heat_df2["num_lanes"],
            y =  car_heat_df2["light_interval"],
            z =  car_heat_df2["changed_lanes"],
            hovertemplate='Number of Lanes: %{x}<br>Green Light Interval: %{y}<br>Count of Lane Changing: %{z}'),
        row=1, col=1,
    )    
    fig.update_xaxes(title_text="Number of Lanes", row=1, col=1)
    fig.update_yaxes(title_text="Light Interval", row=1, col=1)
    fig.update_layout(
        height = 600,
        width = 500,
        title_text = "Change lanes vs Num lanes & Light int",
        showlegend=True
    )
    return fig

#### Graph 5: subplot of change lanes vs num lanes and change lanes vs light int
def create_cars_plot5(num_cars = 10, num_ped = 10, patience=0.6):
    data = get_data(num_cars, num_ped, patience)

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
        subplot_titles=("Number of cars changing lanes vs light interval",
            "Number of cars changing lanes vs number of lanes"
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
        )

    trace3 =go.Line(x = car_interval3["light_interval"],
        y = car_interval3["changed_lanes"],
        name = "number of lanes = 3",
        )

    trace4 =go.Line(x = car_interval4["light_interval"],
        y = car_interval4["changed_lanes"],
        name = "number of lanes = 4",               
        )
    
    # creating subplot 1
    fig.add_trace(trace1, row=1, col=1,),
    fig.add_trace(trace2, row=1, col=1,),
    fig.add_trace(trace3, row=1, col=1,),
    fig.add_trace(trace4, row=1, col=1,)

    #traces for subplot 1 (speed vs num of lanes)
    trace_1 = go.Line(x = car_lanes1["num_lanes"],
                      y = car_lanes1["changed_lanes"],
                      name = "light_interval = 0.5",
                      legendgroup='2')
    trace_2 = go.Line(x = car_lanes2["num_lanes"],
                      y = car_lanes2["changed_lanes"],
                      name = "light_interval = 1.0",
                      #legendgroup='1'
                      )
    trace_3 = go.Line(x = car_lanes3["num_lanes"],
                      y = car_lanes3["changed_lanes"],
                      name = "light_interval = 1.5",
                      #legendgroup='1'
                      )
    trace_4 = go.Line(x = car_lanes4["num_lanes"],
                      y = car_lanes4["changed_lanes"],
                      name = "light_interval = 2.0",
                      #legendgroup='1'
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
    fig.update_xaxes(title_text="Light Interval", row=1, col=1)
    fig.update_xaxes(title_text="Number of Lanes", row=2, col=1)

    fig.update_yaxes(title_text="Number of cars changing lanes", row=1, col=1)
    fig.update_yaxes(title_text="Number of cars changing lanes", row=2, col=1)

    fig.update_layout(
        height = 600,
        width = 600,
        showlegend=True
    )
    return fig



### THE APP


app = dash.Dash(external_stylesheets=[dbc.themes.BOOTSTRAP, 'https://codepen.io/chriddyp/pen/bWLwgP.css'])

#### TAB 1 CONTENT
content1 = dbc.Row([
    dbc.Col([
        html.H6("Number of Lanes"),
        html.Div(
            [
                dbc.Button("Decrease Lane", id = "decrease_lane", color = "danger", className = "me-1", n_clicks = 0),
                html.Span(id="number-of-lanes", style={"verticalAlign": "middle"}),
                dbc.Button("Increase Line", id = "increase_lane", color = "success", className = "me-1", n_clicks = 1),
            ]
        ),
        html.H6("Green to Red Ratio"),
        html.Div(
            [
                dbc.Button("-", id = "decrease_light", color = "danger", className = "me-1", n_clicks = 0),
                html.Span(id="light-interval", style={"verticalAlign": "middle"}),
                dbc.Button("+", id = "increase_light", color = "success", className = "me-1", n_clicks = 1),
            ]
        ),
    ], width = 3),
    dbc.Col([
        html.H6("Average Waiting Time"),
        dbc.Row([
            dbc.Col([daq.Gauge(
                    showCurrentValue=True,
                    color={"gradient":True, 
                            "ranges":{"green":[0,60], "yellow":[60,80],"red":[80,100],"purple": [100, 120]}},
                    scale={'start': 0, 'interval': 10, 'labelInterval': 3},
                    units="seconds",
                    id='test01',
                    label='Avg Waiting Time (Cars)',  #### to-do: need change to avg speed of cars/road congestion lvl
                    max=120,
                    min=0,
                    size = 200
                )], width = 6),
            dbc.Col([daq.Gauge(
                    showCurrentValue=True,
                    color={"gradient":True, 
                            "ranges":{"green":[0,60], "yellow":[60,80],"red":[80,100],"purple": [100, 120]}},
                    scale={'start': 0, 'interval': 10, 'labelInterval': 3},
                    units="seconds",
                    value=75,
                    label='Avg Waiting Time (Pedestrians)', ## to-do: need change to speed/crowd size of pedestrians
                    max=120,
                    min=0,
                    size = 200
                )], width = 6)
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
                ], width = 6), #heatmap of num_change_lanes vs num_lanes and light int
                dbc.Col([
                    dcc.Graph(id = "cars_plot5", figure=create_cars_plot5())
                ], width = 4) #subplots of num_change_lanes
            ])
    ], label = "Lane changing count"),
    dcc.Tab([
        dbc.Row([
                dbc.Col([
                    dcc.Graph(id = "cars_plot2", figure=create_cars_plot2())
                    ], width = 6), #heatmap of speed vs num_lanes and light int
                dbc.Col([
                    dcc.Graph(id = "cars_plot3", figure=create_cars_plot3())
                ], width = 4) #subplots of speed
            ])
    ], label = "Car speed")
])

###TAB 3 CONTENT
content3 = html.Div([
    dcc.Graph(id = "comparing-graph", figure =create_plot_crowd_car() )
])


### OVERALL

## SIDEBAR

sidebar = html.Div([
    html.H6("Number of Cars"),
    dcc.Slider(id = "number-of-cars", min = 5, max = 45, step = 10,
    marks={
        5: "5",
        15: "15",
        25: "25",
        35: "35",
        45: "45"
    }, value=15, 
        tooltip={"placement": "bottom", "always_visible": True}),

    html.Br(),
    html.Br(),

    html.H6("Number of Pedestrians"),
    dcc.Slider(id = "number-of-pedestrians", min = 5, max = 45, step = 10,
    marks={
        5: "5",
        15: "15",
        25: "25",
        35: "35",
        45: "45"
    }, 
    value=15, 
        tooltip={"placement": "bottom", "always_visible": True}),

    html.Br(),
    html.Br(),

    html.H6("Max patience"),
    dcc.Slider(id = "max-patience", min = 0, max = 1, step = 0.2, value=1, 
        tooltip={"placement": "bottom", "always_visible": True}),
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


app.layout = html.Div(
    children=[
        html.H1("Junction Simulation"),
        dbc.Row([ 
            dbc.Col([
                sidebar
            ], width = 2),
            dbc.Col([
                tabs
            ], width = 10)
        ])
    ],
    style={"margin-left": "20px", "margin-right": "20px", "margin-top": "15px"}
)


#####CALLBACKS

# callback for lane buttons
@app.callback(
    Output("number-of-lanes", "children"), [Input("increase_lane", "n_clicks"), Input("decrease_lane", "n_clicks")]
)
def on_button_click(n, m):
    return f"{n - m} lanes"

# callback for light interval buttons
@app.callback(
    Output("light-interval", "children"), [Input("increase_light", "n_clicks"), Input("decrease_light", "n_clicks")]
)
def on_button_click(n, m):
    return format((n - m) / 2, '.1f')

# callback from sidebar to tab 1
@app.callback(
    Output("test01", "value"), 
    [Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value"),
    Input("number-of-lanes", "children"),
    Input("light-interval", "children"),]
)
def get_value(nc, np, mp, nl, li):
    datause = get_data(nc, np, mp)
    data3 = datause[datause['num_lanes'] == int(nl[0])]
    data4 = data3[data3['light_interval'] == float(li)]
    return_value = data4['avg_speed_cars'].iloc[0]
    return return_value



# Callback from sidebar to tab 3
@app.callback(
    Output("comparing-graph", "figure"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_crowd(nc, np, mp):
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    crowd_car_fig = create_plot_crowd_car(default["num_cars"], default["num_pedestrians"], default["patience"])
    return crowd_car_fig

# Callback from sidebar to tab-2-2
# plot 1

@app.callback(
    Output("cars_plot1", "figure"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_cars1(nc, np, mp):
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    car_fig = create_cars_plot1(default["num_cars"], default["num_pedestrians"], default["patience"])
    return car_fig

# plot 2
@app.callback(
    Output("cars_plot2", "figure"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_cars2(nc, np, mp):
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    car_fig = create_cars_plot2(default["num_cars"], default["num_pedestrians"], default["patience"])
    return car_fig

# plot 3
@app.callback(
    Output("cars_plot3", "figure"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_cars3(nc, np, mp):
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    car_fig = create_cars_plot3(default["num_cars"], default["num_pedestrians"], default["patience"])
    return car_fig

# plot 4
@app.callback(
    Output("cars_plot4", "figure"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_cars4(nc, np, mp):
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    car_fig = create_cars_plot4(default["num_cars"], default["num_pedestrians"], default["patience"])
    return car_fig

# plot 5
@app.callback(
    Output("cars_plot5", "figure"),
    Input("number-of-cars", "value"),
    Input("number-of-pedestrians", "value"),
    Input("max-patience", "value")
)
def update_cars5(nc, np, mp):
    if nc:
        default["num_cars"] = nc
    if np:
        default["num_pedestrians"] = np
    if mp:
        default["patience"] = mp
    car_fig = create_cars_plot5(default["num_cars"], default["num_pedestrians"], default["patience"])
    return car_fig



if __name__ == '__main__':
    app.run_server(debug=True, port = 8055)
