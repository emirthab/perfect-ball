using Godot;
using System;

public class enemy : KinematicBody
{
    private bool die = false;
    private RigidBody player;
    private bool chase = false;

    [Export]
    private float speed;

    private Vector3 rushVec;
    private bool inactive = false;
    private Timer inactiveTimer = new Timer();
    
    [Export]
    private float inactiveWaitTime;

    [Export]
    private float rushSpeed;
    
    public override void _Ready()
    {
        inactiveTimer.WaitTime = inactiveWaitTime;
        inactiveTimer.OneShot = true;
        inactiveTimer.Connect("timeout",this,"inactiveTimeout");
        AddChild(inactiveTimer);

        player = GetNode<RigidBody>("../../player");
        GetNode<Area>("outside").Connect("body_entered",this,"outSideEntered");   
        GetNode<Area>("inside").Connect("body_entered",this,"inSideEntered");   
    }


    public override void _Process(float delta)
    {

            
    }

    public override void _PhysicsProcess(float delta)
    {
        if (chase == true && die == false)
        {
            Vector3 direction = player.GlobalTransform.origin - this.GlobalTransform.origin;
            this.MoveAndCollide(direction * speed * delta);
        }
        else if (die == true && inactive == false)
        {
            this.MoveAndCollide(rushVec * speed * delta);
        }

    }

    public void inSideEntered(RigidBody body)
    {
        if (body == player)
        {
            rushVec = player.GlobalTransform.origin - this.GlobalTransform.origin;
            speed = rushSpeed;
            die = true;
            inactiveTimer.Start();
        }
    }

    public void outSideEntered(RigidBody body)
    {
        if (body == player)
        {
            chase = true;
        }
    }
    public void inactiveTimeout()
    {
        inactive = true;
    }
}
