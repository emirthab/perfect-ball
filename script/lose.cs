using Godot;
using System;

public class lose : Node2D
{
    public override void _Ready()
    {

        GetNode<Button>("restart_button").Connect("pressed",this,"restartPressed");

    }

    public void restartPressed()
    {
        GetTree().ReloadCurrentScene();    
    }
}
