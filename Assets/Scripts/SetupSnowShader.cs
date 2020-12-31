using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetupSnowShader : MonoBehaviour
{
    [SerializeField] RenderTexture tex;
    [SerializeField] Transform target;
    Camera orthoCam;

    int shaderPosId = Shader.PropertyToID("_CameraPosition");
    int rtId = Shader.PropertyToID("_RenderTexture");
    int camSizeId = Shader.PropertyToID("_OrthographicCameraSize");

    private void Awake()
    {
        orthoCam = GetComponent<Camera>();
    }

    void Start()
    {
        
        Shader.SetGlobalTexture(rtId, tex);
        Shader.SetGlobalFloat(camSizeId, orthoCam.orthographicSize);
        
    }

    private void Update()
    {
        Shader.SetGlobalVector(shaderPosId, target.position);
    }

}
