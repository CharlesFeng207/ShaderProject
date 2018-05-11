using UnityEngine;
using System.Collections;
using System;

public class ShakeWave : MonoBehaviour
{
    public HeatDistortion heatDistortion;

    public AnimationCurve distanceCurve;
    public AnimationCurve forceCurve;
    public AnimationCurve RradiusCurve;

    void Update()
    {
        if(Input.GetKeyUp(KeyCode.Q))
        {
            StartEffect(() => new Vector2(300, 300));
        }
    }

    public void StartEffect(Func<Vector2> onGetCenter)
    {
        DistortionInstance instance = new DistortionInstance();
        instance.timeLimited = 0.5f;
        instance.distance = 200;
        instance.Force = 0.1f;
        instance.Radius = 50f;
        instance.OnUpdate = OnUpdate;
        instance.OnGetCenter = onGetCenter;
        heatDistortion.TaskEnqueue(instance);
    }

    void OnUpdate(DistortionInstance instance)
    {
        float progress = instance.timeElapsed / instance.timeLimited;

        float distance = instance.distance * distanceCurve.Evaluate(progress);
        float Force = instance.Force * forceCurve.Evaluate(progress);
        float Radius = instance.Radius * RradiusCurve.Evaluate(progress);

        heatDistortion.SetCenter(instance.slotIndex, instance.OnGetCenter());
        heatDistortion.SetDistance(instance.slotIndex, distance);
        heatDistortion.SetForce(instance.slotIndex, Force);
        heatDistortion.SetRadius(instance.slotIndex, Radius);
    }
}
