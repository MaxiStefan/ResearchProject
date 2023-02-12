using System.Diagnostics;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(p => p.AddPolicy("corsapp", builder =>
{
    builder.WithOrigins("*").AllowAnyMethod().AllowAnyHeader();
}));

// Add services to the container.

var app = builder.Build();

// Configure the HTTP request pipeline.

app.UseHttpsRedirection();
app.UseCors("corsapp");


app.MapGet("/start", () =>
{

    string experimentDurationEnv = Environment.GetEnvironmentVariable("ExperimentDuration");
    int experimentDuration = 60;

    if (!string.IsNullOrEmpty(experimentDurationEnv))
    {
        experimentDuration = int.Parse(experimentDurationEnv);
    }

    Stopwatch stopWatch = new Stopwatch();
    stopWatch.Start();

    while (stopWatch.Elapsed.Minutes <= experimentDuration)
    {
        Random rnd = new Random();
            int[] array = new int[50000];

        //Generating the array
        for (int i = 0; i < array.Length; i++)
            {
                array[i] = rnd.Next(1, 3500);

        }

        //Sorting the array
        for (int j = 0; j <= array.Length - 2; j++)
            {
                //array.Length - 2
                for (int i = 0; i <= array.Length - 2; i++)
                {
                    if (array[i] > array[i + 1])
                    {
                        int temp = array[i + 1];
                        array[i + 1] = array[i];
                        array[i] = temp;
                    }
                Console.WriteLine("Exchanged " + array[i+1] + "with " + array[i]);

            }
        }
    }

});

app.Run();
