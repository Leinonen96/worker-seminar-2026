import type {
  Task,
  PaginatedResponse,
  Category,
  TaskStatus,
  TaskApplicant,
  TaskFilters,
  CategoryResponse,
  LocationResponse,
  UserDto,
} from "../types";

// This is a file for interacting with the backend task API.
// It uses the Fetch API to make HTTP requests.
// GET requests are public and don't require authentication.

const API_BASE_URL = import.meta.env.VITE_API_URL || "http://localhost:8080/api";

export type TaskApplicationDetails = TaskApplicant & {
  user?: UserDto & {
    profileImageUrl?: string;
    averageRating?: number;
  };
  task?: {
    id: number;
    title: string;
    categories?: CategoryResponse[];
    locations?: LocationResponse[];
  };
};

export interface FetchTasksParams extends TaskFilters {
  page?: number;
  size?: number;
}

/**
 * Convert frontend sortBy to Spring Pageable sort parameter
 */
function getSortParam(sortBy?: string): string | undefined {
  switch (sortBy) {
    case 'newest':
      return 'startDate,desc'; // Sort by start date descending (newest first)
    case 'oldest':
      return 'startDate,asc'; // Sort by start date ascending (oldest first)
    case 'priceAsc':
      return 'price,asc'; // Sort by price ascending (cheapest first)
    case 'priceDesc':
      return 'price,desc'; // Sort by price descending (most expensive first)
    case 'nearest':
      // For nearest, we'd need to calculate distance on backend
      // For now, just use default sorting
      return undefined;
    default:
      return undefined;
  }
}

// Fetch tasks with optional pagination and filtering
export async function fetchTasks(
  params: FetchTasksParams = {}
): Promise<PaginatedResponse<Task>> {
  const { 
    page = 0, 
    size = 10, 
    searchText,
    categories,
    minPrice,
    maxPrice,
    latitude,
    longitude,
    radiusKm,
    status,
    sortBy
  } = params;

  const queryParams = new URLSearchParams({
    page: page.toString(),
    size: size.toString(),
  });

  // Add text search
  if (searchText && searchText.trim()) {
    queryParams.append("searchText", searchText.trim());
  }

  // Add multiple categories
  if (categories && categories.length > 0) {
    categories.forEach(cat => queryParams.append("categories", cat));
  }

  // Add price range
  if (minPrice !== undefined && minPrice !== null) {
    queryParams.append("minPrice", minPrice.toString());
  }
  if (maxPrice !== undefined && maxPrice !== null) {
    queryParams.append("maxPrice", maxPrice.toString());
  }

  // Add location proximity
  if (latitude !== undefined && longitude !== undefined && radiusKm !== undefined) {
    queryParams.append("latitude", latitude.toString());
    queryParams.append("longitude", longitude.toString());
    queryParams.append("radiusKm", radiusKm.toString());
  }

  // Add status
  if (status) {
    queryParams.append("status", status);
  }

  // Add sorting
  const sortParam = getSortParam(sortBy);
  if (sortParam) {
    queryParams.append("sort", sortParam);
  }

  const response = await fetch(
    `${API_BASE_URL}/task/all-tasks?${queryParams.toString()}`,
    {
      headers: {
        "Content-Type": "application/json",
      },
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Failed to fetch tasks: ${response.status} ${errorText}`);
  }
  return response.json();
}

// Fetch user's own tasks (requires authentication)
export async function fetchUserTasks(
  getAccessToken: () => Promise<string>,
  params: FetchTasksParams = {}
): Promise<PaginatedResponse<Task>> {
  const { 
    page = 0, 
    size = 10, 
    searchText,
    categories,
    minPrice,
    maxPrice,
    latitude,
    longitude,
    radiusKm,
    status,
    sortBy
  } = params;

  const token = await getAccessToken();

  const queryParams = new URLSearchParams({
    page: page.toString(),
    size: size.toString(),
  });

  // Add text search
  if (searchText && searchText.trim()) {
    queryParams.append("searchText", searchText.trim());
  }

  // Add multiple categories
  if (categories && categories.length > 0) {
    categories.forEach(cat => queryParams.append("categories", cat));
  }

  // Add price range
  if (minPrice !== undefined && minPrice !== null) {
    queryParams.append("minPrice", minPrice.toString());
  }
  if (maxPrice !== undefined && maxPrice !== null) {
    queryParams.append("maxPrice", maxPrice.toString());
  }

  // Add location proximity
  if (latitude !== undefined && longitude !== undefined && radiusKm !== undefined) {
    queryParams.append("latitude", latitude.toString());
    queryParams.append("longitude", longitude.toString());
    queryParams.append("radiusKm", radiusKm.toString());
  }

  // Add status
  if (status) {
    queryParams.append("status", status);
  }

  // Add sorting
  const sortParam = getSortParam(sortBy);
  if (sortParam) {
    queryParams.append("sort", sortParam);
  }

  const response = await fetch(`${API_BASE_URL}/task/user-tasks?${queryParams.toString()}`, {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Failed to fetch user tasks: ${response.status} ${errorText}`);
  }

  return response.json();
}

// Fetch workers own tasks (requires authentication)
export async function fetchWorkerTasks(
  getAccessToken: () => Promise<string>,
  params: FetchTasksParams = {}
): Promise<PaginatedResponse<Task>> {
  const { 
    page = 0, 
    size = 10, 
    searchText,
    categories,
    minPrice,
    maxPrice,
    latitude,
    longitude,
    radiusKm,
    status,
    sortBy
  } = params;

  const token = await getAccessToken();

  const queryParams = new URLSearchParams({
    page: page.toString(),
    size: size.toString(),
  });

  // Add text search
  if (searchText && searchText.trim()) {
    queryParams.append("searchText", searchText.trim());
  }

  // Add multiple categories
  if (categories && categories.length > 0) {
    categories.forEach(cat => queryParams.append("categories", cat));
  }

  // Add price range
  if (minPrice !== undefined && minPrice !== null) {
    queryParams.append("minPrice", minPrice.toString());
  }
  if (maxPrice !== undefined && maxPrice !== null) {
    queryParams.append("maxPrice", maxPrice.toString());
  }

  // Add location proximity
  if (latitude !== undefined && longitude !== undefined && radiusKm !== undefined) {
    queryParams.append("latitude", latitude.toString());
    queryParams.append("longitude", longitude.toString());
    queryParams.append("radiusKm", radiusKm.toString());
  }

  // Add status
  if (status) {
    queryParams.append("status", status);
  }

  // Add sorting
  const sortParam = getSortParam(sortBy);
  if (sortParam) {
    queryParams.append("sort", sortParam);
  }

  const response = await fetch(`${API_BASE_URL}/task/worker-tasks?${queryParams.toString()}`, {
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`Failed to fetch user tasks: ${response.status} ${errorText}`);
  }

  return response.json();
}

export interface TaskCategoryInput {
  title: Category | string;
  categoryId?: number;
}

export interface TaskLocationInput {
  streetAddress: string;
  postalCode: string;
  city: string;
  country: string;
  latitude?: number;
  longitude?: number;
}

export interface CreateTaskInput {
  categories: TaskCategoryInput[];
  title: string;
  price: number;
  startDate: string;
  endDate: string;
  location: TaskLocationInput;
  description?: string;
  status?: TaskStatus;
}

// Create a new task (requires authentication)
export async function createTask(
  getAccessTokenSilently: () => Promise<string>,
  payload: CreateTaskInput
): Promise<Task> {
  const token = await getAccessTokenSilently();
  const { location, ...rest } = payload;

  const response = await fetch(`${API_BASE_URL}/task`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      ...rest,
      locations: location ? [location] : [],
    }),
  });

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Failed to create task: ${response.status} ${text}`);
  }

  const data = await response.json();
  const [primaryLocation] = Array.isArray(data.locations)
    ? data.locations
    : [];
  return {
    ...data,
    location: primaryLocation,
  };
}

// Fetch task details by ID
export async function fetchTaskById(taskId: number): Promise<Task> {
  const response = await fetch(`${API_BASE_URL}/task/${taskId}`, {
    headers: {
      "Content-Type": "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch task ${taskId}: ${response.statusText}`);
  }

  const data = await response.json();
  const [primaryLocation] = Array.isArray(data.locations)
    ? data.locations
    : [];
  return {
    ...data,
    location: primaryLocation,
  };
}

// Fetch all applications for a task
export async function fetchTaskApplications(
  taskId: number,
  params: { page?: number; size?: number } = {}
): Promise<PaginatedResponse<TaskApplicant>> {
  const { page = 0, size = 10 } = params;

  const queryParams = new URLSearchParams({
    page: page.toString(),
    size: size.toString(),
  });

  const response = await fetch(
    `${API_BASE_URL}/task/${taskId}/applications?${queryParams.toString()}`,
    {
      headers: {
        "Content-Type": "application/json",
      },
    }
  );

  if (!response.ok) {
    throw new Error(`Failed to fetch applications: ${response.statusText}`);
  }

  return response.json();
}

// Update an existing task (requires authentication)
export async function updateTask(
  getAccessTokenSilently: () => Promise<string>,
  taskId: number,
  payload: CreateTaskInput
): Promise<Task> {
  const token = await getAccessTokenSilently();
  const { location, ...rest } = payload;

  const response = await fetch(`${API_BASE_URL}/task/${taskId}`, {
    method: "PUT",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      ...rest,
      locations: location ? [location] : [],
    }),
  });

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Failed to update task: ${response.status} ${text}`);
  }

  const data = await response.json();
  const [primaryLocation] = Array.isArray(data.locations)
    ? data.locations
    : [];
  return {
    ...data,
    location: primaryLocation,
  };
}

// Delete an existing task (requires authentication)
export async function deleteTask(
  getAccessTokenSilently: () => Promise<string>,
  taskId: number
): Promise<void> {
  const token = await getAccessTokenSilently();

  const response = await fetch(`${API_BASE_URL}/task/${taskId}`, {
    method: "DELETE",
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(`Failed to delete task: ${response.status} ${text}`);
  }
}

// Fetch application details for a specific user and task (requires authentication)
export async function fetchApplicationDetails(
  taskId: number,
  username: string,
  accessToken: string
): Promise<TaskApplicationDetails> {
  const res = await fetch(`${API_BASE_URL}/task/${taskId}/user/${encodeURIComponent(username)}/application`, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
  });
  if (!res.ok) {
    const errorText = await res.text().catch(() => "");
    throw new Error(`Hakemuksen tiedot eivät löytyneet (${res.status}): ${errorText}`);
  }
  const data = (await res.json()) as TaskApplicationDetails;
  return data;
}

// Update application status (accept/reject) - requires authentication
export async function updateApplicationStatus(
  getAccessToken: () => Promise<string>,
  taskId: number,
  applicantUsername: string,
  status: 'ACCEPTED' | 'REJECTED'
): Promise<void> {
  const token = await getAccessToken();

  const response = await fetch(`${API_BASE_URL}/tasks/${taskId}/applications/${encodeURIComponent(applicantUsername)}/status`, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ status }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error('API Error:', response.status, errorText);
    throw new Error(`Failed to update application status: ${response.status} ${errorText}`);
  }
}

export async function completeTaskExecution(
  getAccessTokenSilently: () => Promise<string>,
  taskId: number
): Promise<void> {
  await updateTaskStatus(getAccessTokenSilently, taskId, "PENDING_APPROVAL");
}

/** Update task status (approve/reject work) */
export async function updateTaskStatus(
  getAccessTokenSilently: () => Promise<string>,
  taskId: number,
  status: string
): Promise<void> {
  const token = await getAccessTokenSilently();

  const response = await fetch(`${API_BASE_URL}/task/${taskId}/status`, {
    method: "PATCH",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ taskStatus: status }),
  });

  if (!response.ok) {
    const text = await response.text().catch(() => "");
    throw new Error(text || `Statuksen päivittäminen epäonnistui (${response.status})`);
  }
}
