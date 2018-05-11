using System;
using System.Collections.Generic;
using UnityEngine;
using UnityStandardAssets.ImageEffects;
using System.Linq;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class HeatDistortion : PostEffectsBase
{

    public Shader shader = null;
    public Material material = null;
    public Texture _NoiseTex; 

    public override bool CheckResources()
    {
        CheckSupport(false);

        material = CheckShaderAndCreateMaterial(shader, material, InitMaterial);

        if (!isSupported)
            ReportAutoDisable();

        return isSupported;
    }

    private void InitMaterial(Material m)
    {
        m.SetTexture("_NoiseTex", _NoiseTex);

        // Init slots
        distortionSlot = new Dictionary<int, DistortionInstance>();
        for (int i = 0; i < MAX_TASK; i++)
        {
            distortionSlot.Add(i, null);
        }
    }

    public void OnDisable()
    {

    }

    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (CheckResources() == false)
        {
            Graphics.Blit(source, destination);
            return;
        }

        Graphics.Blit(source, destination, material);
    }

    #region Task Manager

    public const int MAX_TASK = 3;
    private Dictionary<int, DistortionInstance> distortionSlot;

    public void TaskEnqueue(DistortionInstance distotion)
    {

        foreach(int i in distortionSlot.Keys)
        {
            if(distortionSlot[i] == null)
            {
                // Assign data
                distotion.slotIndex = i;
                distortionSlot[i] = distotion;
                return;
            }
        }

#if UNITY_EDITOR
            Debug.Log("HeatDistortion:: no Slots, cancel task");
#endif
        
    }

    public void Reset()
    {
        pendingDelete = distortionSlot.Values.ToList<DistortionInstance>();
        ProcessPendingDelete();
    }

    private List<DistortionInstance> pendingDelete = new List<DistortionInstance>();
    void Update()
    {
        if (distortionSlot == null) return;
        // Process update 
        foreach (DistortionInstance instance in distortionSlot.Values)
        {
            if (instance == null) continue;

            if(instance.Update())
            {
                pendingDelete.Add(instance);
            }
        }

        ProcessPendingDelete();
    }

    private void ProcessPendingDelete()
    {
        // Process deleting
        if (pendingDelete.Count != 0)
        {
            for (int i = 0; i < pendingDelete.Count; i++)
            {
                if (pendingDelete[i] == null) continue;
                DestroyDistortionInstance(pendingDelete[i]);
            }

            pendingDelete.Clear();
        }
    }

    private void DestroyDistortionInstance(DistortionInstance delInstance)
    {
        delInstance.OnUpdate = null; // Clear reference
        delInstance.OnGetCenter = null;
        ResetSlot(delInstance.slotIndex); // Hide effect
        distortionSlot[delInstance.slotIndex] = null; // Reset record
    }

    #endregion

    #region Material interface

    public void ResetSlot(int slotIndex)
    {
        SetForce(slotIndex, 0f);
    }

    public void SetForce(int slotIndex, float value)
    {
        material.SetFloat("_Force" + slotIndex, value);
    }

    public void SetDistance(int slotIndex, float value)
    {
        material.SetFloat("_Distance" + slotIndex, value);
    }

    public void SetRadius(int slotIndex, float value)
    {
        material.SetFloat("_Radius" + slotIndex, value);
    }

    public void SetCenter(int slotIndex, Vector2 value)
    {
        material.SetVector("_Center" + slotIndex, value);
    }

    #endregion
}

public class DistortionInstance
{

    public float timeLimited;
    public Action<DistortionInstance> OnUpdate;
    public Func<Vector2> OnGetCenter;

    public float distance;
    public float Force;
    public float Radius;

    public float timeElapsed;
    internal int slotIndex;

    public bool Update()
    {
        timeElapsed += Time.deltaTime;

        if (timeElapsed >= timeLimited)
        {
            return true;
        }

        if (OnUpdate != null)
            OnUpdate(this);

        return false;
    }

}

