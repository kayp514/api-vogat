import { NextResponse } from 'next/server'
import { getAllWorkspaces, createWorkspace } from '@/lib/db/queries'

const DEFAULT_TENANT_ID = 'default'

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const maxResults = searchParams.get('maxResults')
    const nextPage = searchParams.get('nextPage')

    const result = await getAllWorkspaces(
      maxResults ? parseInt(maxResults) : undefined,
      nextPage ? parseInt(nextPage) : undefined
    )

    if (!result.success) {
      return NextResponse.json(
        {
          success: false,
          error: result.error
        },
        { status: 500 }
      )
    }

    return NextResponse.json({
      success: true,
      workspaces: result.workspaces,
      totalCount: result.totalCount,
      totalPages: result.totalPages,
      currentPage: result.currentPage,
      hasMore: result.hasMore
    })

  } catch (error) {
    console.error('Workspace API error:', error)
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to fetch workspaces'
        }
      },
      { status: 500 }
    )
  }
}

export async function POST(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const uid = searchParams.get('uid')
    const tenantId = searchParams.get('tenantId') || DEFAULT_TENANT_ID

    if (!uid) {
      return NextResponse.json(
        {
          success: false,
          error: {
            code: 'INVALID_INPUT',
            message: 'uid is required'
          }
        },
        { status: 400 }
      )
    }

    const { name, description, type } = await request.json()

    if (!name?.trim()) {
      return NextResponse.json(
        {
          success: false,
          error: {
            code: 'INVALID_INPUT',
            message: 'Workspace name is required'
          }
        },
        { status: 400 }
      )
    }

    // Validate workspace type
    if (type && !['personal', 'business'].includes(type)) {
      return NextResponse.json(
        {
          success: false,
          error: {
            code: 'INVALID_INPUT',
            message: 'Workspace type must be either "personal" or "business"'
          }
        },
        { status: 400 }
      )
    }

    const result = await createWorkspace(
      uid,
      tenantId,
      name,
      description,
      type || 'personal'
    )

    if (!result.success) {
      return NextResponse.json(
        {
          success: false,
          error: result.error
        },
        { status: 500 }
      )
    }

    return NextResponse.json(
      {
        success: true,
        workspace: result.workspace
      },
      { status: 201 }
    )

  } catch (error) {
    console.error('Error creating workspace:', error)
    return NextResponse.json(
      {
        success: false,
        error: {
          code: 'INTERNAL_ERROR',
          message: 'Failed to create workspace'
        }
      },
      { status: 500 }
    )
  }
}