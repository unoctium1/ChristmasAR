using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using ARWT.Marker;
using UnityEngine.Playables;

public class StartOnMarkerDetected : MonoBehaviour
{
    PlayableDirector dir;

    bool isFirstTime = true;

    // Start is called before the first frame update
    void Start()
    {
        dir = GetComponent<PlayableDirector>();

        DetectionManager.onMarkerVisible += onMarkerVisible;
        DetectionManager.onMarkerLost += onMarkerLost;
    }

    void onMarkerVisible(MarkerInfo m)
    {
        if (isFirstTime)
        {
            dir.Play();
            isFirstTime = false;
        }
        else if (dir.state == PlayState.Paused) dir.Resume();
    }

    void onMarkerLost(MarkerInfo m)
    {
        if (dir.state == PlayState.Playing) dir.Pause();
    }


}
