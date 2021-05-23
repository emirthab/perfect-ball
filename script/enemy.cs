using Godot;
using System;

public class enemy : KinematicBody
{
    [Export]
    private float kickPowerUp;
    [Export]
    private float kickPowerHorizontal;
    private AnimationPlayer animPlayer;
    private bool die = false;
    private RigidBody player;
    private bool chase = false;

    [Export]
    private float speed;

    private bool inactive = false;
    private Timer inactiveTimer = new Timer();
    
    [Export]
    private float inactiveWaitTime;

    [Export]
    private float rushSpeed;
    Vector3 direction;
    public override void _Ready()
    {
        animPlayer = GetNode<AnimationPlayer>("enemy/AnimationPlayer");
        GetNode<MeshInstance>("inside/MeshInstance").QueueFree();
        GetNode<MeshInstance>("outside/MeshInstance").QueueFree();
        
        inactiveTimer.WaitTime = inactiveWaitTime;
        inactiveTimer.OneShot = true;
        inactiveTimer.Connect("timeout",this,"inactiveTimeout");
        AddChild(inactiveTimer);

        player = GetNode<RigidBody>("../player/body");
        GetNode<Area>("outside").Connect("body_entered",this,"outSideEntered");   
        GetNode<Area>("inside").Connect("body_entered",this,"inSideEntered");   
        GetNode<Area>("touchPoint").Connect("body_entered",this,"TouchEntered");

        animPlayer.Play("idle");
    }

    public override void _PhysicsProcess(float delta)
    {
        if (!IsOnFloor())
        {
            //Gravity
            this.MoveAndCollide(new Vector3(0,-0.1F,0));
        }

        if (chase == true && die == false)
        {
            direction = player.GlobalTransform.origin - this.GlobalTransform.origin;
        }
        if (inactive == false)
        {
            LookAt(-direction+this.GlobalTransform.origin,Vector3.Up);
            this.MoveAndCollide(direction * speed * delta);

        }

    }

    public void inSideEntered(RigidBody body)
    {
        if (body == player && die == false)
        {
            animPlayer.Play("slide");
            speed = rushSpeed;
            die = true;
            inactiveTimer.Start();
        }
    }

    public void outSideEntered(RigidBody body)
    {
        if (body == player && die == false)
        {
            animPlayer.Play("run");
            chase = true;
        }
    }
    public void inactiveTimeout()
    {
        player.Set("touching",false);
        inactive = true;
    }

    public void TouchEntered(RigidBody body)
    {
        if (body == player && inactive == false)
        {
            player.Set("touching",true);
            Vector3 impulse = new Vector3(direction * kickPowerHorizontal);
            impulse.y = kickPowerUp;
            player.ApplyImpulse(new Vector3(0,0,0),impulse);
        }
    }
}
