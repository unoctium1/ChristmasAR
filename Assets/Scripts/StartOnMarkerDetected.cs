using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ARWT.Marker;
using UnityEngine.Playables;

public class StartOnMarkerDetected : MonoBehaviour
{
    PlayableDirector dir;

    bool isFirstTime;

    private void Awake()
    {
        dir = GetComponent<PlayableDirector>();
        isFirstTime = true;
    }

    void Start()
    {
        

        DetectionManager.onMarkerVisible += StartPlayable;
        DetectionManager.onMarkerLost += StopPlayable;
    }

    void StartPlayable(MarkerInfo m)
    {
        /*
        if (isFirstTime)
        {
            dir.Play();
            isFirstTime = false;
        }
        else */if (dir.state == PlayState.Paused) dir.Resume();
    }

    void StopPlayable(MarkerInfo m)
    {
        if (dir.state == PlayState.Playing) dir.Pause();
    }


}
