using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ArtificialParent : MonoBehaviour
{
    [SerializeField] Transform parent;



    // Update is called once per frame
    void LateUpdate()
    {
        transform.SetPositionAndRotation(parent.position, parent.rotation);
    }
}
