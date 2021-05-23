using Godot;
using System;

public class win : Node2D
{
    public override void _Ready()
    {
        GetNode<Button>("next_button").Connect("pressed",this,"nextPressed");
        GetNode<Button>("restart_button").Connect("pressed",this,"restartPressed");
        
    }

  public override void _Process(float delta)
    {
      
    }
    public void nextPressed()
    {
        GD.Print("aksjdlafsm");
        int currentSceneName = GetTree().CurrentScene.Name.ToInt();
        String nextScenePath = "res://levels/level_"+(currentSceneName+1)+".tscn";
        GetTree().ChangeScene(nextScenePath);
    }

    public void restartPressed()
    {
        GetTree().ReloadCurrentScene();    
    }
}
