using UnityEngine;

public class GraphicsInit : MonoBehaviour
{
    public float ShadowLightAngle = 30f;
    public float ShadowAngle = 30f;
    public Color ShadowColor;

    public Vector3 ShadowDir;
    public Vector3 SimLightDir;

    public void Start()
    {
        DontDestroyOnLoad(gameObject);

        Init();
    }

    private void Init()
    {
        SimLightDir = transform.localRotation * Vector3.up;
        Shader.SetGlobalVector("_SimLightDir", SimLightDir);

        Shader.SetGlobalFloat("_lightRad", ShadowLightAngle * Mathf.Deg2Rad);

        ShadowDir = Quaternion.Euler(0f, 0f, ShadowAngle) * Vector3.right;
        Shader.SetGlobalVector("_shadowDir", ShadowDir);
        Shader.SetGlobalColor("_shadowColor", ShadowColor);
    }

    void OnDrawGizmosSelected()
    {
        Init();

        DebugExtension.DebugArrow(transform.position, SimLightDir, Color.yellow);
    }
}