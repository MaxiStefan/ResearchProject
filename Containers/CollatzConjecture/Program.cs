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

    ulong collatzConjecture = Int32.MaxValue;

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
        Console.WriteLine(collatzConjecture);

        if(collatzConjecture == 1)
        {
            collatzConjecture = Int32.MaxValue;
        }
        else
        {
            if (collatzConjecture % 2 == 0)
            {
                collatzConjecture /= 2;
            }
            else
            {
                collatzConjecture = collatzConjecture * 3 + 1;
            }
            Console.WriteLine("New value " + collatzConjecture);
        }
    }

});

app.Run();
