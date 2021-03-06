using Godot;
using System;

public class player_movement : RigidBody
{
    private bool touching = false;
    private KinematicBody enemy;
    [Export]
    private float minShootPower;
    private bool canShoot = false;
    [Export]
    private float shootWaitTime;
    private Timer shootTimer = new Timer();
    private Vector2 firstPos = new Vector2(0,0);
    private Vector2 currentPos;
    private Vector3 movement;

    [Export]
    private float speedRatio;

    [Export]
    private float maxVelocity;
    private RayCast rayCast;

    //pivot' s lookAt vector so this is targetLook node' s position.
    private Vector3 lookVector(){
        Position3D targetLook = GetNode<Position3D>("../../targetLook");
        Vector3 targetOrgin = targetLook.Transform.origin;
        return targetOrgin;
    }
    public override void _Ready()
    {
        shootTimer.WaitTime = shootWaitTime;
        shootTimer.OneShot = true;
        AddChild(shootTimer);
        rayCast = GetNode<RayCast>("../pivot/RayCast");
        GetNode<Area>("../../deathArea").Connect("body_entered",this,"deathEntered");   
        GetNode<Area>("../../goal").Connect("body_entered",this,"goalEntered");   
        shootTimer.Connect("timeout",this,"shootTimeOut");
    }

    public override void _PhysicsProcess(float delta)
    {

        //The result is calculated by subtracting the first vector from the current vector.

        float posX = (currentPos.x - firstPos.x) * speedRatio;
        float posY = (currentPos.y - firstPos.y) * speedRatio;

        float pivotRotationY = GetNode<Spatial>("../pivot").Rotation.y;
        movement = new Vector3(posX,0,posY);

        //rotate swipe touch vector from pivot
        //The player is moved taking into account the direction the pivot is facing.
        movement = movement.Rotated(new Vector3(0,1,0).Normalized(),pivotRotationY);
        movement.Normalized();

        if (rayCast.IsColliding())
        {
            if (((Node) rayCast.GetCollider()).Name != "enemy" && !touching)
            {
                clampVelocity();
            }
        }
        if (firstPos != new Vector2(0,0) && rayCast.IsColliding())
        {
            ApplyImpulse(new Vector3(0,0,0),movement);
        }

    }

    public override void _Input(InputEvent inputEvent){
        
        //I used a mouse to debug. will be added as touch.
        //The first clicked (touched) position is assigned to the variable "firstPos".
        //If there is movement, the current mouse position is assigned to the "currentPos" variable.
    
        if (inputEvent is InputEventMouseButton mouseEvent)
        {
        
        if ((mouseEvent.ButtonIndex == 1) && (mouseEvent.IsPressed()) && rayCast.IsColliding())
            {
                canShoot = true;
                shootTimer.Start();
                firstPos = mouseEvent.Position;

            }
            
        if ((mouseEvent.ButtonIndex == 1) && (!mouseEvent.IsPressed()))
            {
                if (canShoot == true &&  (currentPos.y - firstPos.y < - minShootPower))
                {
                    movement *= 2;
                    movement.y = 40F;
                    ApplyImpulse(new Vector3(0,0,0), movement);
                }

                firstPos = new Vector2(0,0);
            }
        }
        if (inputEvent is InputEventMouseMotion mouseEvent2)
        
        {
            currentPos = mouseEvent2.Position;

        }
    
    }

    public override void _Process(float delta)
    {
        //pivot is looking at targetLook position' s 
        GetNode<Spatial>("../pivot").LookAt(lookVector(),Vector3.Up);

    }
    public void goalEntered(RigidBody body)
    {
        if (body == this)
        {
            Node win = ((PackedScene)ResourceLoader.Load("res://ui/scenes/win.tscn")).Instance();
            AddChild(win);
        }
    }

    public void shootTimeOut()
    {
        canShoot = false;
    }
    public void deathEntered(RigidBody body)
    {
        if (body == this)
        {
            Node lose = ((PackedScene)ResourceLoader.Load("res://ui/scenes/lose.tscn")).Instance();
            AddChild(lose);
        }

    }

    public void clampVelocity()
    {
        //max linear velocity
        if (LinearVelocity.x > maxVelocity && firstPos != new Vector2(0,0))
        {
            LinearVelocity = new Vector3(maxVelocity,0,LinearVelocity.z);
        }
        if (LinearVelocity.z > maxVelocity && firstPos != new Vector2(0,0))
        {
            LinearVelocity = new Vector3(LinearVelocity.x,0,maxVelocity);
        }

        //min linear velocity
        if (LinearVelocity.x < -maxVelocity && firstPos != new Vector2(0,0))
        {
            LinearVelocity = new Vector3(-maxVelocity,0,LinearVelocity.z);
        }
        if (LinearVelocity.z < -maxVelocity && firstPos != new Vector2(0,0))
        {
            LinearVelocity = new Vector3(LinearVelocity.x,0,-maxVelocity);
        }

    }
}
