using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MousePositionRaycast : MonoBehaviour
{
    [SerializeField] Camera cam;
    RaycastHit hit;
    Ray ray;


    // Update is called once per frame
    void Update()
    {
        ray = cam.ScreenPointToRay(Input.mousePosition);
        if(Physics.Raycast(ray, out hit, Mathf.Infinity))
        {
            transform.position = hit.point;
        }

    }
}
